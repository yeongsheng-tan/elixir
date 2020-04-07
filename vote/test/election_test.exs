defmodule ElectionTest do
  use ExUnit.Case
  doctest Election

  setup do
    %{election: %Election{}}
  end

  test "updating election name from a command", ctx do
    command = "name Will Ferrell"
    election = Election.update(ctx.election, command)
    assert election == %Election{name: "Will Ferrell"}
  end

  test "adding a new candidate from a command", ctx do
    command = "add Will Ferrell"
    election = Election.update(ctx.election, command)
    assert Enum.count(election.candidates) == 1
    assert election.candidates == [Candidate.new(1, "Will Ferrell")]
  end

  test "voting for a candidate from a command", ctx do
    command = "add Will Ferrell"
    election = Election.update(ctx.election, command)
    command = "vote 1"
    election = Election.update(election, command)
    updated_candidate = Enum.at(election.candidates, 0)
    assert updated_candidate.votes == 1
  end

  test "invalid command", ctx do
    command = "some random Invalid cmd"
    election = Election.update(ctx.election, command)
    assert "Invalid command!" == election.errors
  end

  test "quitting the app", ctx do
    command = "quit"
    assert :quit == Election.update(ctx.election, command)
  end

end
