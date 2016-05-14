# Description
#   Some analytics about the hubot command's used
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Daniel Petisme <daniel.petisme@gmail.com>


module.exports = (robot) ->
  command_pattern = new RegExp robot.name + " (.*)", "i"
  analytics_key = 'analytics'
  command_analytics = 'command-analytics'
  sorters = {
    asc: (a, b) -> a.score - b.score
    desc: (a, b) -> b.score - a.score
  }

  getOrCreateAnalytics = ->
    analytics = robot.brain.get(analytics_key)
    if analytics == null
      analytics = {}
    return analytics

  getScore = (analytics, command) ->
    score = analytics[command]
    if score == undefined
      score = 0
    return score

  objToArray = (obj) ->
    arr = for key,value of obj
      {command: key, score: value}
    return arr

  ordered = (that, order) ->
    return objToArray(that).sort(sorters[order])

  printScore = (that) ->
    "Command | Score\n" + for _, it of that
      "#{it.command}: #{it.score}\n"


  robot.hear command_pattern, (res) ->
    command = res.match[1]
    analytics = getOrCreateAnalytics()
    score = getScore(analytics, command) + 1
    analytics[command] = score
    robot.brain.set(analytics_key, analytics)
    robot.emit command_analytics, {
      command: command,
      score: score
    }

  robot.respond /score (.*)/, (res) ->
    command = res.match[1]
    if command.length == 0
      res.reply "The proper usage is score <command>"
    else
      res.reply command + ": " + getScore(getOrCreateAnalytics(), command)

  robot.respond /top( (\d+))?( (asc|desc))?/, (res) ->
    count = res.match[2] or 10
    order = res.match[3] or 'desc'
    order = order.trim()
    sorted = ordered(getOrCreateAnalytics(), order)
    answer = printScore(sorted[0..count - 1])
    res.reply answer
