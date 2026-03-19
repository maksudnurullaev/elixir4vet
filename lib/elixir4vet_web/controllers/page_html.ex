defmodule Elixir4vetWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use Elixir4vetWeb, :html

  embed_templates "page_html/*"

  @quotes [
    {
      "\"The greatness of a nation and its moral progress can be judged by the way its animals are treated.\"",
      "Mahatma Gandhi"
    },
    {
      "\"Until one has loved an animal, a part of one's soul remains unawakened.\"",
      "Anatole France"
    },
    {
      "\"Compassion for animals is intimately associated with goodness of character.\"",
      "Arthur Schopenhauer"
    },
    {
      "\"The question is not, Can they reason? nor, Can they talk? but, Can they suffer?\"",
      "Jeremy Bentham"
    },
    {
      "\"Our task must be to free ourselves by widening our circle of compassion to embrace all living creatures and the whole of nature and its beauty.\"",
      "Albert Einstein"
    },
    {
      "\"The time will come when men such as I will look upon the murder of animals as they now look upon the murder of men.\"",
      "Leonardo da Vinci"
    },
    {
      "\"Humanity's true moral test consists of its attitude towards those who are at its mercy: animals.\"",
      "Milan Kundera"
    },
    {
      "\"Until we extend our circle of compassion to all living things, humanity will not find peace.\"",
      "Albert Schweitzer"
    },
    {
      "\"Life is as dear to a mute creature as it is to man. Just as one wants happiness and fears pain, just as one wants to live and not die, so do other creatures.\"",
      "The Dalai Lama"
    },
    {
      "\"If having a soul means being able to feel love and loyalty and gratitude, then animals are better off than a lot of humans.\"",
      "James Herriot"
    },
    {
      "\"You cannot share your life with a dog or a cat and not know perfectly well that animals have personalities and minds and feelings.\"",
      "Jane Goodall"
    },
    {
      "\"The love for all living creatures is the most noble attribute of man.\"",
      "Charles Darwin"
    },
    {
      "\"It takes nothing away from a human to be kind to an animal.\"",
      "Joaquin Phoenix"
    },
    {
      "\"If you pick up a starving dog and make him prosperous, he will not bite you. This is the principal difference between a dog and man.\"",
      "Mark Twain"
    },
    {
      "\"We can judge the heart of a man by his treatment of animals.\"",
      "Immanuel Kant"
    },
    {
      "\"Dogs are not our whole life, but they make our lives whole.\"",
      "Roger Caras"
    },
    {
      "\"Animals can communicate quite well. And they do. And generally speaking, they are ignored.\"",
      "Alice Walker"
    },
    {
      "\"We must fight against the spirit of unconscious cruelty with which we treat the animals. True humanity does not allow us to impose such sufferings on them.\"",
      "Albert Schweitzer"
    }
  ]

  def random_quotes do
    @quotes |> Enum.shuffle() |> Enum.take(3)
  end
end
