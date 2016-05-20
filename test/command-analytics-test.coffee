Helper = require('hubot-test-helper')
chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

helper = new Helper('../src/command-analytics.coffee')

describe 'command-analytics', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/command-analytics')(@robot)

  dummyAnalytics = ->
    return {
    dummy: 6,
    foo: 23,
    bar: 42,
    baz: 4
    hello: 3,
    plop: 3,
    hi: 1,
    help: 100,
    cat_me: 2,
    pug_me: 4,
    vader: 0
    }


  it 'should init the analytics structure when first use', ->
    expect(@room.robot.brain.get 'analytics').to.be.null
    @room.user.say('alice', '@hubot dummy').then =>
      expect(@room.robot.brain.get 'analytics').to.not.be.null

  it 'should emit an event when a command is heard and score updated', ->
    @room.robot.on 'command-analytics', (command_analytics) ->
      expect(command_analytics.command).to.be.eql('dummy')
      expect(command_analytics.score).to.be.eql(1)
    @room.user.say('alice', '@hubot dummy')


  it 'should increment score everytime a command ask to hubo', ->
    @room.user.say('alice', '@hubot dummy')
    @room.user.say('bob', '@hubot dummy').then =>
      analytics = @room.robot.brain.get 'analytics'
      expect(analytics.dummy).to.be.eql 2

  it 'should not parse command', ->
    @room.user.say('alice', '@hubot dummy 1')
    @room.user.say('alice', '@hubot dummy 1')
    @room.user.say('alice', '@hubot dummy 2')
    @room.user.say('alice', '@hubot score dummy')
    @room.user.say('alice', '@hubot score dummy 1')
    @room.user.say('alice', '@hubot score dummy 2').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot dummy 1'],
        ['alice', '@hubot dummy 1'],
        ['alice', '@hubot dummy 2'],
        ['alice', '@hubot score dummy'],
        ['alice', '@hubot score dummy 1'],
        ['alice', '@hubot score dummy 2'],
        ['hubot', '@alice dummy: 0'],
        ['hubot', '@alice dummy 1: 2'],
        ['hubot', '@alice dummy 2: 1']
      ]

  it 'should init the score to 0 if the command has never been used', ->
    @room.user.say('alice', '@hubot score dummy').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot score dummy'],
        ['hubot', '@alice dummy: 0']
      ]

  it 'should display a message if score is invoked without a command', ->

  it 'should display the top 10 in desc order by default', ->
    answer = """
.-----------------.
| Score | Command |
|-------|---------|
|   100 | help    |
|    42 | bar     |
|    23 | foo     |
|     6 | dummy   |
|     4 | baz     |
|     4 | pug_me  |
|     3 | hello   |
|     3 | plop    |
|     2 | cat_me  |
|     1 | top     |
'-----------------'
"""
    @room.robot.brain.set 'analytics', dummyAnalytics()
    @room.user.say('alice', '@hubot top').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot top']
        ['hubot',
         "@alice \n```#{answer}```"]
      ]

  it 'should display the top 3 in asc order', ->
    answer = """
.-------------------.
| Score |  Command  |
|-------|-----------|
|     0 | vader     |
|     1 | hi        |
|     1 | top 3 asc |
'-------------------'
"""
    @room.robot.brain.set 'analytics', dummyAnalytics()
    @room.user.say('alice', '@hubot top 3 asc').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot top 3 asc'],
        ['hubot', "@alice \n```#{answer}```"]
      ]
