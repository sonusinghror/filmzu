//= require handlebars
//= require ember
//= require ember-data
//= require alert
//= require_self
//= require caball
Caball = Ember.Application.create({
  rootElement: '#emberapp',
  ready: function() {
    console.log('Ember is ready!');
  }
});
Caball.IndexController = Ember.ArrayController.extend({
  time: function() {
    return (new Date()).toDateString();
  }.property(),
});
Caball.Router.map(function() {
  this.resource('disputes');
  this.resource('ember');
  console.log('Routes is ready!');
  this.resource('filmmakers', function() {
    this.route('sign_up');
    this.route('sign_in');
    this.route('portfolio');
  });
  this.resource('clients', function() {
    this.route('sign_up');
    this.route('sign_in');
		this.route('create-project');
  });

  Caball.AlphaNumField = Ember.TextField.extend({
    isValid: function() {
      return /^[a-z0-9]+$/i.test(this.get('value'));
    }.property('value'),
    classNameBindings: 'isValid:valid:invalid'
  });

  Caball.TextFieldEmpty = Ember.TextField.extend({
    focusOut: function() {
      var valid = this.get('value') ? valid = true : valid = false;
      this.$().next(".err").remove();

      if(!valid){
        this.$().addClass("invalid").after("<span class='err'>This field is required</span>");
      } else {
        this.$().removeClass("invalid");
      }
    }
  });

});


Caball.FilmmakersSignUpView = Ember.View.extend({
  didInsertElement: function() {
  	var company = this.$(".company")
  	var companybox = this.$('#company')
  	var individual = this.$('#individual')
    /*
  	company.hide();
  	companybox.change(function() {
      company.show();
      individual.prop("checked", false);
  	  var ticked = this.$('.ch-box span.checked');
  	  ticked.removeClass('checked');
  	  console.log('Company Shown!');
    });
  	individual.change(function() {
  	  company.hide();
  	  console.log('Company Hidden!');
  	  company.prop("checked", false);
  	  var ticked = this.$('.ch-box span.checked');
  	  ticked.removeClass('checked');
  	});*/
  }
});
Caball.ApplicationController = Ember.Controller.extend({

  currentPathChanged: function () {
    window.scrollTo(0, 0);
  }.observes('currentPath')

});