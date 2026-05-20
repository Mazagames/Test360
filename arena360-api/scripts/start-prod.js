const { spawnSync } = require('child_process');

const shouldSeed = process.argv.includes('--seed');

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    stdio: 'inherit',
    shell: process.platform === 'win32',
    env: process.env,
  });

  if (result.status !== 0 && !options.allowFailure) {
    process.exit(result.status || 1);
  }

  return result;
}

function main() {
  const recoveries = [
    {
      env: 'PRISMA_RECOVER_REPORT_OUTPUT_LOCALE_MIGRATION',
      migration: '20260329130000_add_project_report_output_locale',
    },
    {
      env: 'PRISMA_RECOVER_WIKI_ATTACHMENTS_MIGRATION',
      migration: '20260415090000_add_wiki_attachments',
    },
  ];

  for (const { env, migration } of recoveries) {
    const shouldRecover = (process.env[env] || '').toLowerCase() === 'true';
    if (!shouldRecover) continue;

    console.log(
      `[startup] ${env}=true, attempting one-time recovery for ${migration} before migrate deploy.`,
    );

    const recovery = run(
      'npx',
      ['prisma', 'migrate', 'resolve', '--rolled-back', migration],
      { allowFailure: true },
    );

    if (recovery.status !== 0) {
      console.log(
        `[startup] Recovery for ${migration} did not complete cleanly. Continuing to migrate deploy in case the migration was already resolved.`,
      );
    }
  }

  run('npx', ['prisma', 'migrate', 'deploy']);
  run('npm', ['run', 'pdf:check']);

  if (shouldSeed) {
    run('npx', ['prisma', 'db', 'seed']);
  }

  run('node', ['dist/main']);
}

main();
