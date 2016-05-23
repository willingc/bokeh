_ = require "underscore"
{expect} = require "chai"
sinon = require "sinon"
utils = require "../../utils"

{Strength, Variable}  = utils.require("core/layout/solver")

{Document} = utils.require("document")
LayoutDOM = utils.require("models/layouts/layout_dom").Model
LayoutDOMView = utils.require("models/layouts/layout_dom").View

dom_left = 12
dom_top = 13
width = 111
height = 443

describe "LayoutDOM.View", ->

  describe "initialize", ->
    afterEach ->
      utils.unstub_solver()

    beforeEach ->
      utils.stub_solver()
      @test_layout = new LayoutDOM()
      @doc = new Document()
      @test_layout.attach_document(@doc)

    it "should set a class of 'bk-layout-fixed' is responsive-mode is fixed", ->
      @test_layout.responsive = 'fixed'
      layout_view = new LayoutDOMView({ model: @test_layout })
      expect(layout_view.$el.attr('class')).to.be.equal 'bk-layout-fixed'

    it "should set a class of 'bk-layout-box' is responsive-mode is box", ->
      @test_layout.responsive = 'box'
      layout_view = new LayoutDOMView({ model: @test_layout })
      expect(layout_view.$el.attr('class')).to.be.equal 'bk-layout-box'

    it "should set a class of 'bk-layout-width_ar' if responsive-mode is width_ar", ->
      @test_layout.responsive = 'width_ar'
      layout_view = new LayoutDOMView({ model: @test_layout })
      expect(layout_view.$el.attr('class')).to.be.equal 'bk-layout-width_ar'

    it "should set a class of 'bk-layout-height_ar' if responsive-mode is height_ar", ->
      @test_layout.responsive = 'height_ar'
      layout_view = new LayoutDOMView({ model: @test_layout })
      expect(layout_view.$el.attr('class')).to.be.equal 'bk-layout-height_ar'

    it "should set an id matching the model.id", ->
      # This is used by document to find the model and its parents on resize events
      layout_view = new LayoutDOMView({ model: @test_layout })
      expect(layout_view.$el.attr('id')).to.equal "modelid_#{@test_layout.id}"

    it.skip "should build the child views", ->
      # needs a test
      null

    it.skip "should trigger a resize event", ->
      # needs a test
      null

  describe "render", ->
    afterEach ->
      utils.unstub_solver()

    beforeEach ->
      solver_stubs = utils.stub_solver()
      @solver_suggest = solver_stubs['suggest']
      @test_layout = new LayoutDOM()
      @doc = new Document()
      @test_layout.attach_document(@doc)
      @test_layout._dom_left = {_value: dom_left}
      @test_layout._dom_top = {_value: dom_top}
      @test_layout._width = {_value: width}
      @test_layout._height = {_value: height}

    it "should set the appropriate style on the element if responsive mode is 'box'", ->
      @test_layout.responsive = 'box'
      layout_view = new LayoutDOMView({ model: @test_layout })
      layout_view.render()
      expected_style = "position: absolute; left: #{dom_left}px; top: #{dom_top}px; width: #{width}px; height: #{height}px;"
      expect(layout_view.$el.attr('style')).to.be.equal expected_style

    it "should set the appropriate style on the element if responsive mode is 'fixed'", ->
      @test_layout.responsive = 'fixed'
      @test_layout.width = 88
      @test_layout.height = 11
      layout_view = new LayoutDOMView({ model: @test_layout })
      layout_view.render()
      expected_style = "width: 88px; height: 11px;"
      expect(layout_view.$el.attr('style')).to.be.equal expected_style

    it "should not call solver suggest_value if the responsive mode is 'box'", ->
      @test_layout.responsive = 'box'
      layout_view = new LayoutDOMView({ model: @test_layout })
      layout_view.render()
      expect(@solver_suggest.called).is.false
    
    it "should call get_height if responsive_mode is 'width_ar'", ->
      @test_layout.responsive = 'width_ar'
      layout_view = new LayoutDOMView({ model: @test_layout })
      spy = sinon.spy(layout_view, 'get_height')
      expect(spy.called).is.false
      layout_view.render()
      expect(spy.calledOnce).is.true

    it "should call get_width if responsive_mode is 'height_ar'", ->
      @test_layout.responsive = 'height_ar'
      layout_view = new LayoutDOMView({ model: @test_layout })
      spy = sinon.spy(layout_view, 'get_width')
      expect(spy.called).is.false
      layout_view.render()
      expect(spy.calledOnce).is.true

    it "should call suggest value with the model height and width if responsive_mode is fixed", ->
      @test_layout.responsive = 'fixed'
      @test_layout.width = 22
      @test_layout.height = 33
      layout_view = new LayoutDOMView({ model: @test_layout })
      layout_view.render()
      expect(@solver_suggest.callCount).is.equal 2
      expect(@solver_suggest.args[0]).to.be.deep.equal [@test_layout._width, 22]
      expect(@solver_suggest.args[1]).to.be.deep.equal [@test_layout._height, 33]

    it "should call suggest value with the value from get_height if responsive_mode is width_ar", ->
      @test_layout.responsive = 'width_ar'
      layout_view = new LayoutDOMView({ model: @test_layout })
      sinon.stub(layout_view, 'get_height').returns(89)
      layout_view.render()
      expect(@solver_suggest.callCount).is.equal 1
      expect(@solver_suggest.args[0]).to.be.deep.equal [@test_layout._height, 89]

    it "should call suggest value with the value from get_width if responsive_mode is height_ar", ->
      @test_layout.responsive = 'height_ar'
      layout_view = new LayoutDOMView({ model: @test_layout })
      sinon.stub(layout_view, 'get_width').returns(222)
      layout_view.render()
      expect(@solver_suggest.callCount).is.equal 1
      expect(@solver_suggest.args[0]).to.be.deep.equal [@test_layout._width, 222]


describe "LayoutDOM.Model", ->

  it "should have default variables", ->
    l = new LayoutDOM()
    expect(l._top).to.be.an.instanceOf(Variable)
    expect(l._bottom).to.be.an.instanceOf(Variable)
    expect(l._left).to.be.an.instanceOf(Variable)
    expect(l._right).to.be.an.instanceOf(Variable)
    expect(l._width).to.be.an.instanceOf(Variable)
    expect(l._height).to.be.an.instanceOf(Variable)
    expect(l._dom_top).to.be.an.instanceOf(Variable)
    expect(l._dom_left).to.be.an.instanceOf(Variable)
    expect(l._whitespace_left).to.be.an.instanceOf(Variable)
    expect(l._whitespace_right).to.be.an.instanceOf(Variable)
    expect(l._whitespace_top).to.be.an.instanceOf(Variable)
    expect(l._whitespace_bottom).to.be.an.instanceOf(Variable)

  it "should return 8 constraints", ->
    l = new LayoutDOM()
    expect(l.get_constraints().length).to.be.equal 8

  it "should have have layoutable methods", ->
    l = new LayoutDOM()
    expect(l.get_constraints).is.a 'function'
    expect(l.get_edit_variables).is.a 'function'
    expect(l.get_constrained_variables).is.a 'function'
    expect(l.get_layoutable_children).is.a 'function'

  it "should return all default constrained_variables in box responsive modes", ->
    l = new LayoutDOM()
    expected_constrainted_variables = {
      'width': l._width
      'height': l._height
      'origin-x': l._dom_left
      'origin-y': l._dom_top
      # whitespace
      'whitespace-top' : l._whitespace_top
      'whitespace-bottom' : l._whitespace_bottom
      'whitespace-left' : l._whitespace_left
      'whitespace-right' : l._whitespace_right
    }
    l.responsive = 'box'
    constrained_variables = l.get_constrained_variables()
    expect(constrained_variables).to.be.deep.equal expected_constrainted_variables

  it "should not return height constraints in fixed responsive mode", ->
    l = new LayoutDOM()
    expected_constrainted_variables = {
      'origin-x': l._dom_left
      'origin-y': l._dom_top
      'whitespace-top' : l._whitespace_top
      'whitespace-bottom' : l._whitespace_bottom
      'whitespace-left' : l._whitespace_left
      'whitespace-right' : l._whitespace_right
      'width': l._width
    }
    l.responsive = 'fixed'
    constrained_variables = l.get_constrained_variables()
    expect(constrained_variables).to.be.deep.equal expected_constrainted_variables

  it "should not return height and width constraints in fixed responsive mode if is_root", ->
    # If it's the root, then the constrained vars get attached to the document,
    # so we can't return the width otherwise it'll get stuck to the window side
    # and will become responsive.
    l = new LayoutDOM()
    l._is_root = true
    expected_constrainted_variables = {
      'origin-x': l._dom_left
      'origin-y': l._dom_top
      'whitespace-top' : l._whitespace_top
      'whitespace-bottom' : l._whitespace_bottom
      'whitespace-left' : l._whitespace_left
      'whitespace-right' : l._whitespace_right
    }
    l.responsive = 'fixed'
    constrained_variables = l.get_constrained_variables()
    expect(constrained_variables).to.be.deep.equal expected_constrainted_variables

  it "should not return height constraint in width_ar responsive modes", ->
    l = new LayoutDOM()
    l.responsive = 'width_ar'
    expected_constrainted_variables = {
      'width': l._width
      'origin-x': l._dom_left
      'origin-y': l._dom_top
      # whitespace
      'whitespace-top' : l._whitespace_top
      'whitespace-bottom' : l._whitespace_bottom
      'whitespace-left' : l._whitespace_left
      'whitespace-right' : l._whitespace_right
    }
    constrained_variables = l.get_constrained_variables()
    expect(constrained_variables).to.be.deep.equal expected_constrainted_variables

  it "should not return width constraint in height_ar responsive modes", ->
    l = new LayoutDOM()
    l.responsive = 'height_ar'
    expected_constrainted_variables = {
      'height': l._height
      'origin-x': l._dom_left
      'origin-y': l._dom_top
      # whitespace
      'whitespace-top' : l._whitespace_top
      'whitespace-bottom' : l._whitespace_bottom
      'whitespace-left' : l._whitespace_left
      'whitespace-right' : l._whitespace_right
    }
    constrained_variables = l.get_constrained_variables()
    expect(constrained_variables).to.be.deep.equal expected_constrainted_variables

  it "should set edit_variable height if responsive mode is width_ar", ->
    l = new LayoutDOM()
    l.responsive = 'width_ar'
    ev = l.get_edit_variables()
    expect(ev.length).to.be.equal 1
    expect(ev[0].edit_variable).to.be.equal l._height
    expect(ev[0].strength._strength).to.be.equal Strength.strong._strength

  it "should set edit_variable width if responsive mode is height_ar", ->
    l = new LayoutDOM()
    l.responsive = 'height_ar'
    ev = l.get_edit_variables()
    expect(ev.length).to.be.equal 1
    expect(ev[0].edit_variable).to.be.equal l._width
    expect(ev[0].strength._strength).to.be.equal Strength.strong._strength

  it "should not set edit_variables if responsive mode is box", ->
    l = new LayoutDOM()
    l.responsive = 'box'
    ev = l.get_edit_variables()
    expect(ev.length).to.be.equal 0

  it "should set edit_variable height and width if responsive mode is fixed", ->
    l = new LayoutDOM()
    l.responsive = 'fixed'
    ev = l.get_edit_variables()
    expect(ev.length).to.be.equal 2
    expect(ev[0].edit_variable).to.be.equal l._height
    expect(ev[0].strength._strength).to.be.equal Strength.strong._strength
    expect(ev[1].edit_variable).to.be.equal l._width
    expect(ev[1].strength._strength).to.be.equal Strength.strong._strength
