Caball.ProjectController = Ember.ObjectController.extend
	
	getValue: (val) ->
		error = false
		unless result = !!@.get(val)
			error = true
			console.log "#{val} has an error"

		@.set("#{val}Error", error)

		result

	validateTitle: ->
		@.getValue('title')
