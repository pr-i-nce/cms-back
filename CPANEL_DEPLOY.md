# Deploying the backend to cPanel

## GitHub Actions upload

The `Deploy CMS to cPanel` workflow builds the backend and uploads `app.js`, `dist/`, `prisma/`, and the npm manifests over SFTP. It does not upload `.env`, `node_modules`, or remove files from the cPanel application directory.

Configure these repository Actions secrets:

- `SFTP_HOST`: hosting server SFTP hostname
- `SFTP_PORT`: SFTP port (usually `22`; optional)
- `SFTP_USERNAME`: cPanel/SFTP account username
- `SFTP_PASSWORD` or `SFTP_PRIVATE_KEY`: one authentication method
- `SFTP_PASSPHRASE`: private key passphrase, if needed
- `SFTP_REMOTE_DIR`: absolute SFTP path to the cPanel Node.js app root

Set the Node.js application root in cPanel to the same directory as `SFTP_REMOTE_DIR`, and set its startup file to `app.js`. cPanel's supported Node.js version must be 22 or a compatible version. The SFTP user must be allowed to write to that directory.

## cPanel runtime setup

In **Setup Node.js App**, choose production mode, set the app root, startup file (`app.js`), and configure the environment variables there. At minimum set `NODE_ENV=production`, `DATABASE_URL` to the Neon connection string, and strong unique `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET` values. Add the deployed frontend origin to `CORS_ORIGINS`. Do not commit or upload `.env` for production.

After the first upload, use cPanel's **Run NPM Install** action for the app. Repeat it when `package.json` or `package-lock.json` changes. Use **Restart** in cPanel after each upload; cPanel may also restart when `tmp/restart.txt` is touched, but this SFTP workflow intentionally does not run remote shell commands.

## Database migrations

Run migrations as a separate, deliberate release step from the cPanel app terminal, with the production app environment selected:

```sh
npm run db:migrate:status
npm run db:migrate:deploy
```

Review and back up the target database before applying a new migration. The current relational-integrity migration can stop if it finds ambiguous or duplicate legacy records. Resolve those records before retrying. Do not point the migration command at a developer's local database.

## Smoke check

After restarting, open `/health` on the backend URL; a healthy process returns JSON with `status: "ok"`. This endpoint confirms the app process responds, not that Neon credentials or migrations are valid. Confirm the database separately in cPanel's terminal using `npm run db:migrate:status` and then sign in / load a members page through the frontend.
