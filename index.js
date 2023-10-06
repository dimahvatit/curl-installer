import { Octokit } from "@octokit/core";

const versionRegex = /(\d+\.\d+\.\d+)/;

async function main() {
    try {
        Bun.spawn(["which", "curl"], {
            async onExit(proc, exitCode, signalCode, error) {
                if (exitCode != 0) { // curl не установлен
                    console.log("curl is currently not isntalled\nproceeding to installation of the latest version");
                    upgradeCurl("0.0.0");
                } else {
                    const currentVersion = await getCurrentVersion();
                    upgradeCurl(currentVersion);
                }
            }
        })
    } catch (err) {
        console.error(`An error occured: ${err}`);
    }
}

// обновление/установка последней версии curl
function upgradeCurl(currentVersion) {
    getLatestRelease().then(latestVersion => {
        const matches = latestVersion.match(versionRegex);

        if (matches && matches.length > 0) {
            const latestVersion = matches[0];
            console.log(`Latest curl release version: ${latestVersion}`);

            if (latestVersion === currentVersion) {
                console.log("You have the latest version of curl.");
            } else {
                console.log("There is a newer version of curl available.");
                console.log("running ./upgrade_curl.sh...");
                Bun.spawn(["upgrade_curl.sh", currentVersion, latestVersion]);
            }
        }
    });
}

// получение текущей версии curl
async function getCurrentVersion() {
    return new Promise(async (resolve, reject) => {
        const checkCurlVer = Bun.spawn(["curl", "--version"], {
            onExit(proc, exitCode, signalCode, error) {
                if (exitCode != 0) {
                    console.error(`Error executing 'curl --version', exit code: ${exitCode}`);
                    reject(new Error(`Error executing 'curl --version', exit code: ${exitCode}`));
                }
            }
        });
        const checkCurlVerResp = await new Response(checkCurlVer.stdout).text();

        const matches = checkCurlVerResp.toString().match(versionRegex);

        if (matches && matches.length > 0) {
            const currentVersion = matches[0];
            console.log(`Installed curl version: ${currentVersion}`);
            resolve(currentVersion);
        } else {
            console.error("Couldn't get installed curl version");
            reject(new Error("Couldn't get installed curl version"));
        }
    });
}

// получение последней версии curl
async function getLatestRelease() {
    try {
        let token = process.env.TOKEN;
        const octokit = new Octokit({
            auth: token
        })

        const response = await octokit.request("GET /repos/{owner}/{repo}/releases/latest", {
            owner: "curl",
            repo: "curl",
            headers: {
                "X-GitHub-Api-Version": "2022-11-28"
            }
        });

        return response.data.name;
    } catch (err) {
        console.error(`Error while fetching latest release: ${err}`);
        throw err;
    }
}

main();
