module API
  class Example < Grape::API
    
    include Grape::ActiveRecord::Extension
    

    get :example do
      {message: 'Hello World!'}
    end
  end
end
