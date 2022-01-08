import tracer from "dd-trace";

export function startTracer(serviceName: string) {
  if (process.env["USE_DATADOG_APM"] === "true") {
    const version = process.env["VERSION"];
    tracer.init({
      service: serviceName,
      version: version,
      plugins: false,
    });
    tracer.use("aws-sdk", {
      service: serviceName,
      splitByAwsService: false
    });
    tracer.use("connect", { service: serviceName });
    tracer.use("dns", { service: serviceName});
    tracer.use("express", {
      service: serviceName,
      blocklist: [
        "/healthz",
        "/livez"
      ],
    });
    tracer.use("fs", { service: serviceName});
    tracer.use("http", { service: serviceName});
    tracer.use("net", { service: serviceName});
    tracer.use("pino", { service: serviceName});
  }
}
