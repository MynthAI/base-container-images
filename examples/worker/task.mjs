// Example task that exercises the combined toolchain of the worker
// image: node orchestrates, while pnpm, fnm, python and uv do the work.
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

// Run a Python calculation with the uv-managed CPython build
const result = Number(
  run("uv", ["run", "python", "-c", "print(sum(range(10)))"]),
);

console.log(JSON.stringify(versions, null, 2));
console.log(`sum(range(10)) computed by uv-managed python: ${result}`);

if (result !== 45) {
  console.error("unexpected python result");
  process.exit(1);
}

console.log("worker task completed");
