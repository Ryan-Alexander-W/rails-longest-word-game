require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def game

    @grid_size = 8
    @letter_grid = generate_grid(@grid_size).join
    @start_time = Time.now.to_i
  end

  def score
    @grid = params[:grid]
    @guess = params[:guess]
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i
    @time_taken = (@end_time - @start_time)
    run_game(@guess, @grid, @start_time, @end_time)
    @results =  score_and_message(@guess, @grid, @time_taken)
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end



  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end
