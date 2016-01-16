require 'test_helper'

class MoviesControllerTest < ActionController::TestCase
  setup do
    @movie = movies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:movies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create movie" do
    assert_difference('Movie.count') do
      post :create, movie: { actors: @movie.actors, countries: @movie.countries, directors: @movie.directors, filming_locations: @movie.filming_locations, genres: @movie.genres, languages: @movie.languages, metascore: @movie.metascore, plot: @movie.plot, rated: @movie.rated, release_date: @movie.release_date, runtime: @movie.runtime, simple_plot: @movie.simple_plot, title: @movie.title, type: @movie.type, url_imdb: @movie.url_imdb, url_poster: @movie.url_poster, votes: @movie.votes, year: @movie.year }
    end

    assert_redirected_to movie_path(assigns(:movie))
  end

  test "should show movie" do
    get :show, id: @movie
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @movie
    assert_response :success
  end

  test "should update movie" do
    patch :update, id: @movie, movie: { actors: @movie.actors, countries: @movie.countries, directors: @movie.directors, filming_locations: @movie.filming_locations, genres: @movie.genres, languages: @movie.languages, metascore: @movie.metascore, plot: @movie.plot, rated: @movie.rated, release_date: @movie.release_date, runtime: @movie.runtime, simple_plot: @movie.simple_plot, title: @movie.title, type: @movie.type, url_imdb: @movie.url_imdb, url_poster: @movie.url_poster, votes: @movie.votes, year: @movie.year }
    assert_redirected_to movie_path(assigns(:movie))
  end

  test "should destroy movie" do
    assert_difference('Movie.count', -1) do
      delete :destroy, id: @movie
    end

    assert_redirected_to movies_path
  end
end
