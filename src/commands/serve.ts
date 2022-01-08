import * as util from "util";
import { Server } from "../server/server";
import * as metrics from "../metrics";

exports.name = "serve";
exports.describe = "Run the server";
exports.builder = {
  bugsnagKey: {
    type: "string",
    demand: false,
  },
};

exports.handler = (argv) => {
  main(argv).catch((err) => {
    console.log(`Failed with error ${util.inspect(err)}`);
    process.exit(1);
  });
};

export async function main(argv: any): Promise<void> {
  metrics.bootstrapFromEnv();

  await new Server(
    argv.bugsnagKey,
  ).start();
}
