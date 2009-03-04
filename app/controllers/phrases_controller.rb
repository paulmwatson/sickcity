class PhrasesController < ApplicationController
  layout 'base'
  def index
    @phrases = Phrase.find :all, :order => 'w'
  end  
end
