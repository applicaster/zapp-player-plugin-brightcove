workflow "Monorepo Build" {
  on = "push"
  resolves = ["CheckChangedFolder"]
}

action "CheckChangedFolder" {
  uses = "./action_repo_here"
}
