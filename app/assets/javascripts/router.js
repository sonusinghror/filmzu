Caball.Router.map(function() {
  this.resource('disputes');	
  console.log('Ember is ready!');	
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
});
