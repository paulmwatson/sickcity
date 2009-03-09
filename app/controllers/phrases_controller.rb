class PhrasesController < ApplicationController
  layout 'base'
  def index
    @phrases = Phrase.find :all, :order => 'title'
  end  
end
