---
tags:
    - git
---
# GitHub workflow

App development loosely follows the [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow)[^1]. Features and fixes are developed on dedicated branches and merged into `main` through pull requests (PRs).

![git-workflow](../assets/images/git-workflow-simple-light.png)

!!! tip

    - Commit often
    - Keep branches short-lived and focused on one feature/fix
    - Squash commits when merging and summarize the branch purpose

## Start with an issue

When fixing a bug or starting work on a new feature, begin by **creating a clear, meaningful issue**. This acts as the source of truth for the work and helps others understand the context and goal.

!!! example

    Currently, the background image of the mobile login page...**{describe problem}**

    **{add image}**

    The background image should be removed. **{propose solution}**

![new-issue](../assets/videos/new-issue.gif)

## Create a branch

Next, **create a branch** for your work and check it out in your local IDE.

![create-branch](../assets/images/create-branch.png)

Commit to your branch frequently to save your progress and make collaboration easier. If you want feedback early, use issue comments and tag teammates using *@username* to get their attention.

## Pull requests & merging

When your branch satisfies the goals of the issue and is ready for integration, **open a pull request :one:** and add someone's name to request their review.

![pull-request](../assets/images/pull-request.png)

!!! warning "Important"

    PR titles must be [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

    *For example:*

        feat: add breadcrumbs
        fix: correct timer calculation
        style: add primary highlight

        BREAKING CHANGE: refactor api routes


Reviewers may suggest improvements or point out issues by commenting directly on specific lines of code. These discussions appear as threaded comments in the PR.

[^1]: [https://docs.github.com/en/get-started/using-github/github-flow](https://docs.github.com/en/get-started/using-github/github-flow)
