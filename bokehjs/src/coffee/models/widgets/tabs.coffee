_ = require "underscore"
$ = require "jquery"
$1 = require "bootstrap/tab"

build_views = require "../../common/build_views"

p = require "../../core/properties"

tabs_template = require "./tabs_template"
Widget = require "./widget"

class TabsView extends Widget.View

  initialize: (options) ->
    super(options)
    @views = {}
    @render()
    @listenTo @model, 'change', this.render

  render: () ->
    super()
    for own key, val of @views
      val.$el.detach()
    @$el.empty()

    tabs = @mget('tabs')
    active = @mget('active')
    children = @mget('tabs_children')

    build_views(@views, children)

    html = $(tabs_template({
      tabs: tabs
      active: (i) -> if i == active then 'bk-bs-active' else ''
    }))

    that = this
    html.find("> li > a").click (event) ->
      event.preventDefault()
      $(this).tab('show')
      panelId = $(this).attr('href').replace('#tab-','')
      tabs = that.model.get('tabs')
      panelIdx = _.indexOf(tabs, _.find(tabs, (panel) ->
        return panel.id == panelId
      ))
      that.model.set('active', panelIdx)
      that.model.get('callback')?.execute(that.model)

    $panels = html.children(".bk-bs-tab-pane")

    for [child, panel] in _.zip(children, $panels)
      $(panel).html(@views[child.id].$el)

    @$el.append(html)
    @$el.tabs
    return @

class Tabs extends Widget.Model
  type: "Tabs"
  default_view: TabsView

  initialize: (options) ->
    super(options)
    @tabs_children = (tab.get("child") for tab in @tabs)

  @define {
      tabs:     [ p.Array,   [] ]
      active:   [ p.Number,  0  ]
      callback: [ p.Instance    ]
    }

  @internal {
      tabs_children: [ p.Array,   [] ]
  }

  get_layoutable_children: () ->
    return @get('tabs_children')

  get_edit_variables: () ->
    edit_variables = super()
    # Go down the children to pick up any more constraints
    for child in @get_layoutable_children()
      edit_variables = edit_variables.concat(child.get_edit_variables())
    return edit_variables

  get_constraints: () ->
    constraints = super()
    # Go down the children to pick up any more constraints
    for child in @get_layoutable_children()
      constraints = constraints.concat(child.get_constraints())
    return constraints

module.exports =
  Model: Tabs
  View: TabsView
