# mad: multi-agent development for claude code

Run Claude Code on different AI models (Grok, Gemini, GPT or any from 500+ on OpenRouter) in parallel. each in its own container, its own branch. compare. merge the best.

never wonder "would another model have done better?"

## why this matters

when you ask an AI to build something, you get one approach. but what if gpt-5 would have made better architectural choices? what if gemini handles edge cases you didn't think of?

mad runs them in parallel. same task, different models, isolated environments. you see all approaches, pick the winner. it's like being a game master for a battle royale, where each model is a contestant and you pick the winner.

i found tooling like Claude Code Router or Claude Code Proxy to be either missing parallel execution w/ containers, or too complex to set up.

ps. you can use this to run Claude Code for free with OpenRouter's free models like Deepseek.

**how it works:**

- choose any 4 models from openrouter's 500+ options
- run 4 models in parallel (you pick which 4)
- each runs Claude Code in a separate docker container
- each works on a separate git branch via worktrees
- watch them all in tmux 2x2 grid
- compare implementations with `mad compare`
- merge the best one with `mad merge <model>`
- currently only macOS supported (sorry windows guys) / porting to linux is trivial

## setup

```bash
# install docker desktop from docker.com/products/docker-desktop
# then install dependencies:
brew install bash tmux

git clone https://github.com/YOUR_USERNAME/mad.git
cd mad

cp .env.example .env
# edit .env: add your api keys

# edit docker/litellm/config.yaml: choose your 4 models from openrouter.ai/models

docker-compose build

echo 'export PATH="$PATH:'$(pwd)'/scripts"' >> ~/.zshrc
source ~/.zshrc
```

## usage

```bash
cd ~/your-project
mad
```

that's it. creates branches, starts containers, opens tmux with 4 panes. each pane runs Claude Code with a different model.

give the same prompt to all 4 and you can relax while clankers work.

```bash
mad compare      # see what each model built
mad merge gemini # merge the best one
mad cleanup      # remove branches/worktrees
```

## workflow

```bash
cd ~/my-project
mad

# tmux opens with 4 panes
# give same task to all models
# let them work in parallel

# detach: ctrl+b then d
# reattach: tmux attach -t mad-<session-name>

mad compare
git checkout main
mad merge gpt5
mad cleanup
```

## commands

| command             | what it does                      |
| ------------------- | --------------------------------- |
| `mad`               | start new session                 |
| `mad compare`       | compare all implementations       |
| `mad merge <model>` | merge specific model's branch     |
| `mad cleanup`       | remove all worktrees and branches |
| `mad stop`          | stop containers and tmux          |

## changing models

edit `docker/litellm/config.yaml`:

```yaml
model_list:
  - model_name: gemini # change this to the model you want to use
    litellm_params:
      model: openrouter/google/gemini-2.5-pro # and this one, based on the link you got from openrouter.ai/models
      api_key: os.environ/OPENROUTER_API_KEY
      api_base: https://openrouter.ai/api/v1
      supports_vision: true
```

browse models at openrouter.ai/models

rebuild:

```bash
docker-compose build
docker-compose up -d
```

## troubleshooting

**containers won't start:** `docker-compose ps` and `docker-compose logs litellm`. rebuild with `docker-compose down && docker-compose build --no-cache && docker-compose up -d`.

**auth errors:** verify keys in `.env` start with `sk-or-v1-` (openrouter) and `sk-ant-api03-` (anthropic). no special characters in comments.

**worktrees:** `git worktree list` to see all, `git worktree prune` to clean.

**disk space:** `./scripts/docker-cleanup` to remove old containers/images.

## how it works

git worktrees give you real filesystem isolation while sharing .git (makes diffs trivial). litellm proxies requests to any model. tmux shows all 4 agents side-by-side.
