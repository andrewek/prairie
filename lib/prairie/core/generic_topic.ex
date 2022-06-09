defmodule GenericTopic do
  @moduledoc """
  Basic Pub/Sub functionality

  Use like this:

  defmodule Prairie.Bison.Topic do
    use GenericTopic, default_topic: "bison"
  end
  """

  defmacro __using__(opts \\ []) do
    default_topic = Keyword.get(opts, :default_topic)

    quote do
      @default_topic unquote(default_topic)

      @doc """
      Subscribe to a topic - accepts either a struct (with an ID) or a string
      binary, or falls back to default topic.
      """
      def subscribe(%_struct_name{id: id} = struct) do
        struct
        |> topic_for()
        |> subscribe()
      end

      def subscribe(topic) when is_binary(topic) do
        Phoenix.PubSub.subscribe(Prairie.PubSub, topic)
      end

      def subscribe() do
        Phoenix.PubSub.subscribe(Prairie.PubSub, default_topic())
      end

      @doc """
      Publish to the topic

      body is typically going to be a tuple, e.g. {:family, :created, record.id}

      topic - accepts either a struct (with an ID) or a string binary, or falls
      back to default topic.
      """
      def broadcast(body, %_some_struct{id: id} = struct) do
        topic = topic_for(struct)
        broadcast(body, topic)
      end

      def broadcast(body, topic) when is_binary(topic) do
        Phoenix.PubSub.broadcast(
          Prairie.PubSub,
          topic,
          body
        )
      end

      def broadcast(body) do
        broadcast(body, default_topic())
      end

      @doc """
      Given a struct with an ID, append that id onto the default topic

      Errors out competely unless you give it a struct with an ID
      """
      def topic_for(%_struct_name{id: id}) do
        "#{default_topic()}:#{id}"
      end

      @doc """
      Let's avoid easy typos, yeah?
      """
      def default_topic() do
        @default_topic
      end

      defoverridable subscribe: 1, broadcast: 2, topic_for: 1
    end
  end
end
