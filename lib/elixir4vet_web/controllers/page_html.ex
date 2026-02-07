defmodule Elixir4vetWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use Elixir4vetWeb, :html

  embed_templates "page_html/*"
end
