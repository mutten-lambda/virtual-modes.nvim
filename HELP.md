# Configuration overview

When calling the `setup()`, a configuration table is expected.
The most general configuration table looks like this:

    {
		keymap_enter_prefix = ...,
		enable_keymap_prefix = ...,
		on_enter = ...,
		on_exit = ...,
		keymaps = ...,
		modes = {
			{
				name = ...,
				keymap_enter = ...,
				enable_keymap_prefix = ...,
				keymaps = ...,
				on_enter = ...,
				on_exit = ...,
			},
			name = {
				keymap_enter = ...,
				enable_keymap_prefix = ...,
				keymaps = ...,
				on_enter = ...,
				on_exit = ...,
			},
			...
		},
	}

# Global versus modal/local options

Some configuration keys are available both globally, and locally for a given virtual mode.
When options cannot be combined, the modal options always take precedence over the global ones.

# Setting a keymap to enter a mode

The simpelest way to set a keymap to enter a mode is by using the `keymap_enter` option.
When `enable_keymap_prefix` is `true`, `keymap_enter_prefix` will be added to this keymap.

When using the following configuration, `<leader>et` will drop you into `TEST` mode.

	{
		keymap_enter_prefix = "<leader>e",
		enable_keymap_prefix = true,
		modes = {
			TEST = {
				keymap_enter = "t"
			}
		}
	}

# Using shared data

The `function`s to be executed when entering or exiting a virtual mode are given two tables as arguments.
They can be used to share data.
The first one is local/modal data and the second one is global.

For example, the `keymaps` logic uses this the restore keymaps which were overwritten when entering a mode.
The old keymaps get stored in `modal_data._old_keymaps` when entering and can be restored when exiting.

# Option specifications

## `keymap_enter_prefix`

The prefix which can optionally be added to `keymap_enter`, (also see `enable_keymap_prefix`). 
Expects a `string`.

## `enable_keymap_prefix`

Whether to add the `keymap_enter_prefix` to `keymap_enter`.
Expects a `bool`.

##	`on_enter`

The actions to be executed when entering a virtual mode.
Expects
  - a `string` to be executed as a vimscript command
  - a `function` (see Using `data`)
  - a `table` containing `string`s and/or `function`s

##	`on_exit`

The actions to be executed when exiting a virtual mode.
Expects
  - a `string` to be executed as a vimscript command
  - a `function` (see Using `data`)
  - a `table` containing `string`s and/or `function`s

## `keymaps`

The new keymaps which should be available in a virtual mode.
Expects a `table` containing arguments for setting a keymap,
i.e. `{ mode, lhs, rhs, opts }`. (See `:h nvim_set_keymap()`)

## `name`

The name of a virtual mode.
This can be omitted when `name` is used as the key of the modal configuration is `modes`.
(See the example at the top.)
Expects a `string`, not equal to `NORMAL`.

## `modes`

Contains the configurations for all the virtual modes.
Expects a `table` containing modal configurations like:

	{
		name = ...,
		keymap_enter = ...,
		enable_keymap_prefix = ...,
		keymaps = ...,
		on_enter = ...,
		on_exit = ...,
	}

or:

	name = {
		keymap_enter = ...,
		enable_keymap_prefix = ...,
		keymaps = ...,
		on_enter = ...,
		on_exit = ...,
		data = ...,
	}
