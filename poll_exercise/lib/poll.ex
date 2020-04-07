defmodule Poll do
  defstruct candidates: []

  def new(candidates \\ []) do
    %Poll{candidates: candidates}
  end

  # TODO: Implement functions neccesary to make the tests in 
  # `test/poll_test.exs` pass. More info in README.md
  def start_link(candidates \\ []) do
    spawn_link(Poll, :run, [candidates])
  end

  def add_candidate(pid, name) when is_pid(pid) and is_binary(name) do
    send(pid, {:add_candidate, name})
  end

  def vote(pid, name) when is_pid(pid) and is_binary(name) do
    send(pid, {:vote, name})
  end

  def candidates(pid) when is_pid(pid) do
    send(pid, {:candidates, self()})
    receive do
      {^pid, candidates} -> candidates
    end
  end

  def exit(pid) when is_pid(pid) do
    send(pid, :exit)
  end

  def run(candidates) when is_list(candidates) do
    receive do
      msg -> handle(msg, candidates)
    end
    |> run()
  end

  def handle({:add_candidate, name}, candidates) do
    [Candidate.new(name) | candidates]
  end

  def handle({:vote, name}, candidates) do
    Enum.map(candidates, &maybe_inc_vote(&1, name))
  end

  def handle({:candidates, pid}, candidates) do
    send(pid, {self(), candidates})
    candidates
  end

  def handle(:exit, pid) do
    Process.exit(self(), :normal)
  end

  def handle(msg, candidates) do
    IO.inspect(msg, label: "Unknown Msg")
    candidates
  end

  defp maybe_inc_vote(candidate, name) when is_binary(name) do
    maybe_inc_vote(candidate, candidate.name == name)
  end

  defp maybe_inc_vote(candidate, _inc_vote = false), do: candidate
  defp maybe_inc_vote(candidate, _inc_vote = true) do
    Map.update!(candidate, :votes, &(&1 + 1))
  end
end
