#!/usr/bin/env ruby

require 'sling/test'
require 'test/unit.rb'
require 'test/unit/ui/console/testrunner.rb'
include SlingSearch

class TC_Kern538Test < SlingTest
  
  #
  # Creating a tree of nodes by posting a block of JSON.
  #
  
  def test_normal
    m = Time.now.to_i.to_s
    treeuser = create_user("treeuser#{m}")    
    @s.switch_user(treeuser)
    
    # Create foo node in private store
    @s.execute_post(@s.url_for("_user/private/foo"), {"foo" => "bar"})
    
    # Create the default tree
    jsonRes = create_tree(default_tree(), "_user/private/foo")
    
    #Assertions
    default_asserts(jsonRes)
  end
  
  def test_with_jcr_in_property
    m = Time.now.to_i.to_s
    treeuser = create_user("treeuser#{m}")    
    @s.switch_user(treeuser)
    
    # Create foo node in private store
    @s.execute_post(@s.url_for("_user/private/foo"), {"foo" => "bar"})
    
    # Create the default tree
    tree = default_tree()
    tree["foo"]["jcr:primaryType"] = "nt:file"
    jsonRes = create_tree(tree, "_user/private/foo")
    
    #Assertions
    default_asserts(jsonRes)
  end
  
  def test_noneExistingResource
    m = Time.now.to_i.to_s
    treeuser = create_user("treeuser#{m}")    
    @s.switch_user(treeuser)
    
    # Create the default tree
    jsonRes = create_tree(default_tree(), "_user/private/test")
    
    #Assertions
    default_asserts(jsonRes)    
  end
  
  def test_accessdenied
    m = Time.now.to_i.to_s
    treeuser = create_user("treeuser#{m}")    
    @s.switch_user(treeuser)
    
    # Create the default tree
    tree = default_tree()
    
    # Actual parameters we're sending in the request.
    parameters = {
      ":operation" => "createTree", 
      "tree" => JSON.generate(tree)
    }
    
    # Execute the post
    res = @s.execute_post(@s.url_for("foo/bar"), parameters)
    
    assert_equal(res.code.to_i, 500, "Expected to fail.")
    
  end
  
  def default_asserts(jsonRes)
    assert_equal(jsonRes["foo"]["title"], "Foo", "Expected to get 'Foo' as title.")
    assert_equal(jsonRes["foo"]["bar1"]["unit"], 1, "Expexted to get a childnode 'bar1' with property unit of '1.5'.")
    assert_equal(jsonRes["foo"]["bar1"]["title"], "First bar", "Expexted to get a childnode 'bar1' with property title of 'First bar'.")
    assert_equal(jsonRes["foo"]["bar2"]["unit"], 2.5, "Expexted to get a childnode 'bar2' with property unit of '2.5'.")
    assert_equal(jsonRes["foo"]["bar2"]["title"], "Second bar", "Expexted to get a childnode 'bar2' with property title of 'Second bar'.")
  end
  
  def default_tree()
    # Our tree should exist out of a node 'foo' with two childnodes 'bar1' and 'bar2'    
    tree = {
        "foo" => {
            "title" => "Foo",
            "bar1" => {
                "title" => "First bar",
                "unit" => 1
        },
            "bar2" => {
                "title" => "Second bar",
                "unit" => 2.5
        }
      }
    }
    
    return tree
  end
  
  def create_tree(tree, url, levels = 5)
    
    # Actual parameters we're sending in the request.
    parameters = {
      ":operation" => "createTree", 
      "tree" => JSON.generate(tree)
    }
    
    # Execute the post
    @s.execute_post(@s.url_for(url), parameters)
    
    # Return the result of that node
    res = @s.execute_get(@s.url_for("#{url}.#{levels}.json"))
    return JSON.parse(res.body)
  end
  
end

Test::Unit::UI::Console::TestRunner.run(TC_Kern538Test)
