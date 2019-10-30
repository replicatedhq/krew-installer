import * as fs from "fs";
import * as path from "path";
import * as _ from "lodash";
import {Service} from "ts-express-decorators";


@Service()
export class Templates {

  private kurlURL: string;
  private replicatedAppURL: string;
  private installTmpl: (any) => string;
  private pluginTmpl: (any) => string;

  constructor () {
    this.kurlURL = process.env["KURL_URL"] || "https://kurl.sh";
    this.replicatedAppURL = process.env["REPLICATED_APP_URL"] || "https://replicated.app";

    const tmplDir = path.join(__dirname, "../../../scripts");
    const installTmplPath = path.join(tmplDir, "install.sh");
    const pluginTmplPath = path.join(tmplDir, "install-plugin.sh");

    const opts = {
      escape: /{{-([\s\S]+?)}}/g,
      evaluate: /{{([\s\S]+?)}}/g,
      interpolate: /{{=([\s\S]+?)}}/g,
    };
    this.installTmpl = _.template(fs.readFileSync(installTmplPath, "utf8"), opts);
    this.pluginTmpl = _.template(fs.readFileSync(pluginTmplPath, "utf8"), opts);
  }

  public renderKrewScript(): string {
    return this.installTmpl({});
  }

  public renderKrewScriptWithPlugin(pluginName: string): string {
    return this.pluginTmpl({"plugin": pluginName});
  }
}
