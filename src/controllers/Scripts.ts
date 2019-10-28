import * as Express from "express";
import {
  Controller,
  Get,
  PathParams,
  Res } from "ts-express-decorators";
import { instrumented } from "monkit";
import { Templates } from "../util/services/templates";

interface ErrorResponse {
  error: any;
}

const notFoundResponse = {
  error: {
    message: "The requested installer does not exist",
  },
};

@Controller("/")
export class Installers {

  constructor (
    private readonly templates: Templates,
  ) {}

  /**
   * /<krewPlugin> handler
   *
   * @param response
   * @param krewPlugin
   * @returns string
   */
  @Get("/:krewPlugin")
  @Get("/:krewPlugin/")
  @instrumented
  public async getInstaller(
    @Res() response: Express.Response,
    @PathParams("krewPlugin") krewPlugin: string,
  ): Promise<string | ErrorResponse> {
    response.status(200);
    return this.templates.renderKrewScriptWithPlugin(krewPlugin);
  }

  @Get("/")
  public async root(
    @Res() response: Express.Response,
  ): Promise<string> {
    response.status(200);
    return this.templates.renderKrewScript();
  }
}
