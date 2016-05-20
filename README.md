# hubot-command-analytics

Some analytics about the hubot command's used

See [`src/command-analytics.coffee`](src/command-analytics.coffee) for full documentation.

*Warning*: To date a command is everything used after the robot name.

```
user1>> hubot cat bomb 1
user1>> hubot cat bomb 2
user1>> hubot cat bomb 3
```
In the above snippet, the analytics will count 3 different commands (instead of counting only 1 command (`hubot cat bomb`) 3 times.  

## Installation

In hubot project repo, run:

`npm install hubot-command-analytics --save`

Then add **hubot-command-analytics** to your `external-scripts.json`:

```json
[
  "hubot-command-analytics"
]
```

## Sample Interaction

```
user1>> hubot hello
...
user1>> hubot score hello
hubot>> user1 hello: 1
user1>> hubot top
hubot>> user1
.---------------------.
| Score |   Command   |
|-------|-------------|
|     1 | hello       |
|     1 | score hello |
|     1 | top         |
'---------------------'
```

## Availabe Commands

* `score <commands>`: how many times <command> has been used
* `top [n] [asc|desc]`: Display the `n` commands order by scores asc or desc. Default `n=10, order=desc`.

## Extension

Every time a command is heard, a `command-analytics` event is emitted.

````
robot.on 'command-analytics', (command_analytics) ->
  robot.send command_analytics.user, "The #{command_analytics.command}'s score is: #{command_analytics.score}"
```` 




