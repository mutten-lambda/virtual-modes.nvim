# virtual-modes.nvim

**This plugin is in an early development stage. Use at your own risk :)**

## Intro

Create custom modes for your favorite text editor.

One of the strengths of Vim is the concept of *modal editing*:
the meaning of what you type depends on context.
This plugin let you be more specific about that context.

When editing, you're probably mostly in `NORMAL` mode.
Often, you're focussing on concrete subtasks:
- jumping around using the `QUICKFIX` or `LOCATION` lists
- fixing your `SPELL`ing
- doing `GIT` stuff
- `DEBUG`ging
- editing markdown `TABLE`s
- clutter-free `ZEN` writing
- ...

The idea of this plugin is to make it easy to make overlays for `NORMAL` mode -- virtual modes --
which behave just like you want in that context.

## Getting started

One thing you can do is adding keymaps, which may overwrite existsing keymaps.
Upon exiting the virtual mode, the old ones get restored.

Say you have the following configuration:

	local opts = { noremap = true }
	{
		modes = {
			QUICKFIX = {
				keymap_enter = "<leader>eq",
				keymaps = {
					{ "n", "<c-n>", "<cmd>cnext<cr>", opts },
					{ "n", "<c-p>", "<cmd>cprev<cr>", opts },
				},
			},
		},
	}

Typing `<leader>eq` (**e**nter **q**uickfix) will drop you into `QUICKFIX` mode
and now two extra keymaps to traverse the quickfix list are available.
Typing `<esc>` will exit this new mode and will remove the keymaps

## Full documentation

Currently in HELP.md.

## TODO

- [ ] add tests
- [ ] validate input
- [ ] normalise input
- [ ] print usefull warnings
- [ ] refactor from local to _ 
- [ ] refactor utils
- [ ] restore old keymaps
- [ ] write toggle utility function to toggle vim options and lua variables
- [ ] write vimdoc documentation
- [ ] write lua documentation
- [ ] add examples to README
- [ ] which-key integration
