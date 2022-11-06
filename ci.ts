import * as commander from 'commander';
import * as fs from 'fs';
import * as fsp from 'fs/promises';
import * as path from 'path';
import dargs from 'dargs';
import got from 'got';
import jsonfile from 'jsonfile';
import semver from 'semver';
import { env } from 'process';
import { execa } from 'execa';
import { step } from '@sigill/watch-your-step';

import { sh_single_quote } from './shell-quoting.js';

interface GhTag {
  name: string;
  // zipball_url: string;
  tarball_url: string;
  // commit: {
  //   sha: string;
  //   url: string;
  // };
  // node_id: string;
}

function positiveInteger(value: string) {
  if (!/^[1-9][0-9]*$/.test(value))
    throw new commander.InvalidArgumentError('Not apositive integer.');

  return value;
}

async function listTags() {
  return got.paginate.all<GhTag>('https://api.github.com/repos/llvm/llvm-project/tags', {
    // cache,
    // cacheOptions: { shared: false }
    http2: true,
    headers: env.GITHUB_TOKEN ? {'authorization': `token ${env.GITHUB_TOKEN}`} : {},
  });
}

function pipe_commands(commands: ReadonlyArray<ReadonlyArray<string>>) {
  return commands.map(command => sh_single_quote(...command)).join(' | ');
}

async function download_and_extract(url: string, archive: string, dest: string, {stripComponents}: {stripComponents?: number} = {}) {
  await fsp.mkdir(dest, { recursive: true });

  const strip_opt = dargs({stripComponents: stripComponents?.toString()} as any, {includes: ['stripComponents']});

  if (fs.existsSync(archive)) {
    return execute(['tar', '-xzf', archive, '-C', dest, ...strip_opt]);
  } else {
    // const a = execa('curl', ['-L', url], {stdin: 'ignore', stdout: 'pipe', stderr: process.stderr});
    // const b = execa('tee', [archive], {stdin: 'pipe', stdout: 'pipe', stderr: process.stderr});
    // a.stdout?.pipe(b.stdin as Writable);
    // const c = execa('tar', ['-xz', '-C', dest, '--strip-components=1'], {stdin: 'pipe', stdout: 'inherit', stderr: process.stderr});
    // b.stdout?.pipe(c.stdin as Writable);
    // return c;
    return execute(['bash', '-c',
                    pipe_commands([
                      ['curl', '-L', url],
                      ['tee', archive],
                      ['tar', '-xz', '-C', dest, ...strip_opt]])]);
  }
}

function pretty_command(command: string[], {env, cwd}: {env?: NodeJS.ProcessEnv, cwd?: string} = {}) {
  const prefix = [];
  if (env || cwd) {
    prefix.push('env');
    if (cwd) {
      prefix.push('-C', cwd);
    }
    if (env) {
      Object.entries(env).forEach(([k, v]) => {
        prefix.push(`${k}=${v}`);
      });
    }
  }
  return sh_single_quote(...prefix, ...command);
}

function execute(command: string[], {title, skip, env, cwd}: {title?: string, skip?: () => boolean | string, env?: NodeJS.ProcessEnv, cwd?: string} = {}) {
  return step({
    title: title || pretty_command(command, {cwd, env}),
    skip,
    action: () => {
      return execa(command[0], command.slice(1), {env, cwd, stdio: 'inherit'})
        .catch(err => {
          if (err.exitCode) {
            if (err.all) console.log(err.all);
            throw new Error(`Command failed with exit code ${err.exitCode}`);
          } else throw err;
        });
    }
  });
}

(async () => {
  const opts = commander.program
  .option('-j <num>', 'Number of threads to use in total.', positiveInteger)
  .option('-k <num>', 'Number of threads to use for compilation.', positiveInteger)
  .option('-l <num>', 'Number of threads to use for link.', positiveInteger)
  .parse().opts();

  const knownTagsFile = path.join(process.cwd(), 'known_tags.json');
  const knownTags: Array<{name: string, version: string}> =
    fs.existsSync(knownTagsFile) ? jsonfile.readFileSync(knownTagsFile) : [];

  const tags = await listTags()
  .then(tags => tags.filter(t => t.name.match(/^llvmorg-\d+\.\d+\.\d+$/)))
  .then(tags => tags.map(t => ({name: t.name, version: t.name.substring('llvmorg-'.length), tarball_url: t.tarball_url})));

  const newTags = tags
  .filter(t => !knownTags.some(kt => kt.name === t.name))
  .sort((v1, v2) => semver.compare(v1.version, v2.version));

  console.log(newTags);

  for (const tag of newTags) {
    const sourceDir = `llvm-project-${tag.version}`;
    await download_and_extract(tag.tarball_url /*`http://localhost:9000/${sourceDir}.tar.gz`*/, `${sourceDir}.tar.gz`, sourceDir, {stripComponents: 1});

    for (const os of ['sles15.3', 'sles15.4', 'centos7']) {
      await execute([
        'bash', 'build-containerized.sh', '--env', os, '--source', sourceDir, '-v', tag.version,
        ...dargs(opts, {includes: ['j', 'k', 'l'], useEquals: false})]);
    }
  }

  jsonfile.writeFileSync(knownTagsFile, tags, {spaces: 2, EOL: '\n'});
})();
