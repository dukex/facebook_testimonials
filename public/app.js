var Route        = ReactRouter.Route;
var DefaultRoute = ReactRouter.DefaultRoute;
var RouteHandler = ReactRouter.RouteHandler;
var Link         = ReactRouter.Link;
var Router       = ReactRouter;

window.startApp = function() {
  var routes = (
    <Route handler={App} path="/">
      <DefaultRoute handler={MyTestimonials} />
      <Route name="user" path=":id" handler={FriendTestimonails} />
    </Route>
  )

  Router.run(routes, function (Handler) {
    React.render(<Handler/>, document.getElementById('container'));
  });
};

var App = React.createClass({
  render: function () {
    return (
      <div>
        <RouteHandler />
      </div>
    )
  }
})

var MyTestimonials = React.createClass({
  getInitialState: function () {
    return { user: {} }
  },

  componentDidMount: function () {
    fetch("/me", {
        credentials: 'include'
      })
      .then(checkStatus)
      .then(parseJSON)
      .then(function(data) {
      if (this.isMounted()) {
        this.setState(data);
      }
    }.bind(this));
  },

  render: function () {
    return (
      <Box user={this.state.user}>
        <h1>seus depoimentos</h1>
      </Box>
    );
  }
});

var FriendTestimonails = React.createClass({
  getInitialState: function () {
    return {
      user: this.context.router.getCurrentParams()
    }
  },
 contextTypes: {
    router: React.PropTypes.func
  },
  componentDidMount: function () {
    debugger
  },
  render: function () {
    return (
      <Box user={this.state.user}>
        <h1>depoimentos dele</h1>
        <TestimonialForm />
      </Box>
    );
  }
});

var Box = React.createClass({
  render: function () {
    return (
      <div className="depo-box">
        {this.props.user}
        {this.props.children}
        <TestimonialList user={this.props.user}/>
      </div>
    )
  }
})

var TestimonialForm = React.createClass({
  render: function () {
    return (
      <form>
        <textarea name="body"></textarea>
      </form>
    )
  }
});

var TestimonialList = React.createClass({
  loadTestimonialsFromServer: function () {
    if (this.props.user && this.props.user.id) {
      fetch("/testimonials/" + this.props.user.id, {
        credentials: 'include'
      })
      .then(checkStatus)
      .then(parseJSON)
      .then(function(data) {
        if (this.isMounted()) {
          this.setState(data);
        }
      }.bind(this));
    }
  },
  pollInterval: 4000,
  getInitialState: function () {
    return { testimonials: [] }
  },
  render: function () {
    this.loadTestimonialsFromServer();

    var testimonials = this.state.testimonials.map(function (testimonial) {
      return (
        <Testimonial key={testimonial.id} testimonial={testimonial} />
      );
    });
    return (
      <div>
        {testimonials}
      </div>
    );
  }
});

var Testimonial = React.createClass({
  render: function () {
    return (
      <div className="testimonial">
        <Link to="user" params={this.props.testimonial.from}><img src={this.props.testimonial.from.image_url} /></Link>
        <div className="body">
        <Link to="user" params={this.props.testimonial.from}>{this.props.testimonial.from.name}</Link>:
          {this.props.testimonial.body}
        </div>
      </div>
    )
  }
});

function checkStatus(response) {
  if (response.status >= 200 && response.status < 300) {
    return response;
  } else {
    var error = new Error(response.statusText);
    error.response = response;
    throw error;
  }
}

function parseJSON(response) {
  return response.json();
}
