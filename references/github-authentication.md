# GitHub Authentication for Git and AI Tools

Git and GitHub authentication are related but separate. A computer can successfully clone, fetch, pull, and push while GitHub CLI is signed out, because Git and `gh` may be using different credentials and different secure stores.

## The layers

| Layer | What it answers | Common mechanisms |
|---|---|---|
| Git transport | Can this computer read or write repository objects? | HTTPS credential helper, SSH key, short-lived service token |
| GitHub API | Can a tool inspect or change pull requests, issues, checks, and other GitHub objects? | GitHub CLI login, OAuth app, personal access token, GitHub App installation token |
| Credential storage | Where does the reusable secret live? | macOS Keychain, Windows Credential Manager, Linux secret service, Git Credential Manager, GitHub CLI's system credential store |
| Interface | What does the person or agent operate? | Git command line, GitHub CLI, GitHub Desktop, IDE, connected app |

The Git author name and email stored in commits are identity metadata, not authentication. They do not grant access and do not need to match a GitHub username, although GitHub can associate an email with an account.

## Standard supported route

For a human collaborator or a local AI agent working interactively, install Git and GitHub CLI, then use GitHub CLI's browser login. GitHub CLI can provide the machine with a supported route for both private-repository access and GitHub API features such as pull-request discovery when Git is also configured to use it.

```bash
gh auth login -h github.com
gh auth status -h github.com
```

Choose HTTPS unless the repository or organisation deliberately standardises on SSH. GitHub CLI stores its token in the operating system's credential store when one is available. It can also configure Git to use GitHub CLI as its HTTPS credential helper:

```bash
gh auth setup-git -h github.com
```

That last command changes Git's credential-helper configuration. Do not run it merely to repair `gh` if ordinary Git already works through another helper; first decide whether to preserve the separate working route or standardise Git on GitHub CLI.

## Supported alternatives

### Operating-system keychains

A keychain is secure credential storage, not a Git protocol or a GitHub client. For example, Git's `osxkeychain` helper stores HTTPS credentials in macOS Keychain; Windows and Linux have equivalent secure-store patterns. This Git credential can remain valid even when GitHub CLI's separately stored token expires.

### HTTPS with Git Credential Manager

[Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager) provides browser-based authentication and stores credentials in the operating system's secure credential store. It is cross-platform and a strong alternative for Git transport, but it does not itself provide GitHub CLI commands or pull-request API output to an app.

### SSH

An SSH key can authenticate Git clone, fetch, pull, and push without an HTTPS token. The private key remains on the machine, usually protected by an SSH agent and optionally a passphrase. SSH does not provide GitHub API access; a tool that needs pull requests or checks still needs `gh`, an app connection, or another API credential.

### GitHub Desktop

GitHub Desktop is a graphical Git client. It authenticates its own GitHub connection over HTTPS and caches credentials for its own use. Its optional command-line installation adds the `github` launcher for opening repositories in Desktop; it does not replace the general `git` command or install GitHub CLI's `gh` command for terminal agents.

### Personal access tokens

A personal access token can authenticate HTTPS Git or the GitHub API when supplied through a secure credential helper or environment variable. It is useful for constrained or headless environments, but interactive collaborators should prefer browser-based OAuth through GitHub CLI or Git Credential Manager. Never put a token in a repository, command history, app UI, issue, or chat.

### GitHub Apps, deploy keys, and machine users

Automation should prefer a narrowly scoped, short-lived GitHub App installation token where practical. Deploy keys are repository-scoped SSH credentials and can be appropriate for a single service or deployment. A dedicated machine user is a broader organisational pattern that needs deliberate access governance. These mechanisms are for services and automation, not the default collaborator setup.

### Agent connectors

An AI product's connected GitHub app or OAuth session may allow that product to inspect repository or pull-request data. It does not automatically authenticate local `git` or the local `gh` process. Treat it as a separate application boundary unless the product explicitly documents a shared credential bridge.

## What an AI agent can actually use

A local terminal agent can usually run whatever authenticated tools are already available in its environment: `git` for repository transport and `gh` for GitHub API operations. A sandboxed or hosted agent may instead receive a product-managed connector, a short-lived token, or no write credentials at all. Never infer one channel from another: test each required capability without displaying the secret.

For a private repository, the common capability split is:

| Task | Required authenticated channel |
|---|---|
| Clone, fetch, pull, push | Git over HTTPS or SSH |
| List or inspect private pull requests from the terminal | GitHub CLI or another authenticated GitHub API client |
| Open the repository in GitHub Desktop | GitHub Desktop's own signed-in connection |
| Run unattended automation | GitHub App token, workflow token, deploy key, or deliberately managed service credential |

## Safe diagnosis

These checks identify the configured route and test access without printing stored credentials:

```bash
git remote get-url origin
git config --show-origin --get-all credential.helper
gh auth status -h github.com
git ls-remote --exit-code origin HEAD
```

- If `git ls-remote` works but `gh auth status` fails, Git transport is authenticated and only GitHub CLI needs repair.
- If an HTTPS Git operation fails, repair the configured credential helper or deliberately standardise on GitHub CLI or Git Credential Manager.
- If an SSH Git operation fails, inspect the remote, loaded key, and GitHub SSH association before changing credentials.
- If `gh` works but Git fails, inspect the Git remote protocol and credential-helper configuration; API authentication alone does not prove Git transport access.

## Recovery guidance

For an expired interactive GitHub CLI login, run `gh auth login -h github.com` and use the browser flow. Verify with `gh auth status -h github.com` and a read-only API request such as `gh api user --jq .login`. Use `gh auth setup-git -h github.com` only when you deliberately want Git's HTTPS operations to use GitHub CLI as their credential helper.

For onboarding, document the supported default first and the alternatives second: Git plus authenticated private-repository access is the required capability; GitHub CLI is the standard supported authentication and GitHub-integration route; SSH and Git Credential Manager are supported advanced Git-transport alternatives; API-dependent workflows still require an authenticated API client.

## Official references

- [GitHub CLI authentication](https://cli.github.com/manual/gh_auth_login)
- [Configure Git to use GitHub CLI as a credential helper](https://cli.github.com/manual/gh_auth_setup-git)
- [Caching GitHub credentials in Git](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git)
- [Git credential helpers](https://git-scm.com/docs/gitcredentials.html)
- [GitHub Desktop connections](https://docs.github.com/en/desktop/installing-and-authenticating-to-github-desktop/about-connections-to-github-in-github-desktop)
- [GitHub Desktop command-line launcher](https://docs.github.com/en/desktop/overview/launching-github-desktop-from-the-command-line)
- [Managing deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys)
- [GitHub App installation access tokens](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app)
