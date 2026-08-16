// Example task for the worker image: node orchestrates the pnpm, fnm
// and uv toolchains.
import { execFileSync } from "node:child_process";

const run = (command, args) =>
  execFileSync(command, args, { encoding: "utf8" }).trim();

const versions = {
  node: process.version,
  npm: run("npm", ["--version"]),
  pnpm: run("pnpm", ["--version"]),
  fnm: run("fnm", ["--version"]),
  python: run("python", ["--version"]),
  uv: run("uv", ["--version"]),
  uvx: run("uvx", ["--version"]),
};

// Route the calculation through uv to exercise the managed CPython build
const result = Number(
  run("uv", ["run", "python", "-c", "print(sum(range(10)))"]),
);

console.log(JSON.stringify(versions, null, 2));
console.log(`sum(range(10)) computed by uv-managed python: ${result}`);

if (result !== 45) {
  console.error(`unexpected python result: ${result}`);
  process.exit(1);
}

console.log("worker task completed");
