import Octokit from "@octokit/rest";
import { log } from "../../logger";
import moment from "moment";

export class KrewVersion {
    private octokit: Octokit;
    private lastChecked: Date;
    private lastVersion: string;

    constructor () {
        this.octokit = new Octokit({userAgent: "krew-installer"});
        this.lastVersion = "atestvalue";
        this.updateVersion();
    }

    public async getKrewVersion(): Promise<string> {
        if (moment(Date()).isAfter(moment(this.lastChecked).add(1, "hour"))) {
            await this.updateVersion();
        }

        return this.lastVersion;
    }

    private async updateVersion() {
        log("updating krew version");
        try {
            let release = await this.octokit.repos.getLatestRelease({owner: "kubernetes-sigs", repo: "krew"});
            if (release.status >= 400) {
                log("unable to query github", release.status);
                return;
            }
            this.lastVersion = release.data.tag_name;
            this.lastChecked = new Date();
            log("found krew version: " + this.lastVersion);
        } catch (e) {
            log("exception updating krew version", e);
        }

        return;
    }
}
