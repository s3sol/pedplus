class App.Models.CountSession extends Backbone.Model
  name: 'count_session'
  
  initialize: (args) ->
    @counts = new App.Collections.Counts
    @bind "change", =>
      @counts.url = "/api/projects/#{masterRouter.projects.getCurrentProjectId()}/count_sessions/#{@id}/counts"
    , this

  getGate: ->
    masterRouter.gates.get @get 'gate_id'

  getSegment: ->
    masterRouter.count_session.get @get 'segment_id'

  durationMinutes: ->
    minutes = XDate(@get 'start').diffMinutes(@get 'end')
    # only show one decimal point of accuracy
    minutes.toFixed(1)

  select: ->  
    @collection.selectNone() # only want one CountSession selected at a time
    @set
      selected: true
    # masterRouter.navigate "#project/#{masterRouter.projects.getCurrentProjectId()}/measure/count_session/#{@id}", true
  deselect: ->
    # if masterRouter.currentRouteName == "measureSelectedCountSession:#{@cid}"
    # else if masterRouter.currentRouteName == "measureEnterCountSession:#{@cid}"
    # else if masterRouter.currentRouteName == "measureDeleteCountSession:#{@cid}"
        
    # if this CountSession is not already selected, then we want its 
    # @set() command to be silent and not fire a changed event
    alreadySelected = @get 'selected'
    @set
      selected: false
    , 
      silent: !alreadySelected
  toggle: ->
    if @get 'selected'
      @deselect()
    else
      @select()