Caball.ProjectView = Ember.View.extend
  templateName: 'project'

Caball.TitleTextField = Ember.TextField.extend
	focusOut: (event) ->
		controller = @.get('parentView.controller')
		viewName = @.get('viewName')
		validatorName = "#{Em.String.classify(viewName)}"
		controller["validate#{validatorName}"]())
