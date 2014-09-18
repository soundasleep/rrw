require 'test_helper'

class BlockerTest < ActiveSupport::TestCase
  test "we have blockers to test" do
    assert_not_equal 0, Blocker.all.length || 0
  end

  test "all blockers have Npcs" do
    Blocker.all.each do |b|
      assert_not_nil b.npc, "Blocker #{b} does not have an Npc"
    end
  end

  test "all blockers have Connections" do
    Blocker.all.each do |b|
      assert_not_nil b.connection, "Blocker #{b} does not have a Connection"
    end
  end

  # test that any 'requires deaths' is defined corectly
  Blocker.all.select { | b | b.connection }.each do |b|
    c = b.connection
    test "blocker #{b.id} for connection #{c.from} to #{c.to} has a valid death target" do
      assert_equal b.npc.space, c.from, "Blocking NPC #{b.npc.name} was not in #{c.from.name} but in #{b.npc.space.name}"
    end
  end

  test "blocked_by" do
    connection = Connection.new
    npc = Npc.new(name: "Fred")
    blocker = Blocker.new(npc: npc, connection: connection)
    blocker.save()

    assert_true connection.is_blocked?
    assert_equal "Fred", connection.blocked_by
  end

  test "blocked_by with multiple" do
    connection = Connection.new
    npc1 = Npc.new(name: "Fred")
    blocker = Blocker.new(npc: npc1, connection: connection)
    blocker.save()
    npc2 = Npc.new(name: "Bob")
    blocker = Blocker.new(npc: npc2, connection: connection)
    blocker.save()

    assert_true connection.is_blocked?
    assert_equal "Fred", connection.blocked_by
  end

  test "blocked_by a dead creature" do
    connection = Connection.new
    npc = Npc.new(name: "Fred")
    npc.current_health = 0
    blocker = Blocker.new(npc: npc, connection: connection)
    blocker.save()

    assert_false connection.is_blocked?
  end

end
