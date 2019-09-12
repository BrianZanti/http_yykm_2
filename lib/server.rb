# Library that contains TCPServer
require 'socket'
require './lib/request'

class Server
  def initialize
    generate_answer
    @server = TCPServer.new(9292)
  end

  def generate_answer
    @answer = rand(0..100)
  end

  def start
    # Create a new instance of TCPServer on Port 9292
    loop do
      main_loop
    end
  end

  def main_loop
    # Wait for a Request
    # When a request comes in, save the connection to a variable
    puts 'Waiting for Request...'
    connection = @server.accept

    # Read the request line by line until we have read every line
    puts "Got this Request:"

    request_lines = read_request(connection)

    request = Request.new(request_lines)

    content_length = request.headers["Content-Length"]
    if content_length
      body = read_body(connection, content_length)
      request.parse_body(body)
    end

    # request.verb
    # request.params
    # request.path

    # Print out the Request
    puts request_lines

    # Generate the Response
    puts "Sending response."

    response = make_response(request)

    # Send the Response
    connection.puts response

    # close the connection
    connection.close
  end

  def read_body(connection, content_length)
    connection.read(content_length.to_i)
  end

  def read_request(connection)
    request_lines = []
    line = connection.gets.chomp
    while !line.empty?
      request_lines << line
      line = connection.gets.chomp
    end
    request_lines
  end

  def make_response(request)
    if request.path.include? "/dogs"
      response = dog_response(request)
    elsif request.path.include? "/game"
      response = game_response(request)
    elsif request.path.include? "/congratulations"
      output = "<html><img src='https://media.giphy.com/media/g9582DNuQppxC/giphy.gif' alt='hello'></html>"
      status = "http/1.1 200 ok"
      response = status + "\r\n" + "\r\n" + output
    else
      response = root_response(request)
    end
    response
  end

  def game_response(request)
    if request.params.include? "answer"
      @answer = request.params["answer"].to_i
      output = "<html>You have changed the answer</html>"
      status = "http/1.1 200 ok"
    elsif request.params.include? "guess"
      guess = request.params["guess"].to_i
      output = make_guess(guess)
      if guess == @answer
        status = "http/1.1 301 redirect\nLocation: /congratulations"
      else
        status = "http/1.1 200 ok"
      end
    elsif request.path.include? "answer"
      output = "<html>The answer is #{@answer}</html>"
      status = "http/1.1 200 ok"
    elsif request.verb == "DELETE"
      output = "<html>A new answer has been generated</html>"
      status = "http/1.1 200 ok"
      generate_answer
    else
      output = "<html>I've generated a random number between 1 and 100. Start guessing!#{main_page}</html>"
      status = "http/1.1 200 ok"
    end
    status + "\r\n" + "\r\n" + output
  end

  def make_guess(guess)
    if guess < @answer
      return "<html>too low</html>"
    elsif guess > @answer
      return "<html>too high</html>"
    else
      return "<html>correct!</html>"
    end
  end

  def dog_response(request)
    if request.verb == "GET"
      output = "<html>Look at all the dogs!</html>"
      status = "http/1.1 200 ok"
    elsif request.verb == "POST"
      output = "<html>creating a dog! WOOOO!</html>"
      status = "http/1.1 200 ok"
    elsif request.verb == "PATCH"
      output = "<html>updating a dog! WOOOO!</html>"
      status = "http/1.1 200 ok"
    elsif request.verb == "DELETE"
      output = "<html>destroying a dog! NOOOO!</html>"
      status = "http/1.1 200 ok"
    else
      output = "<html>404 Not Found</html>"
      status = "http/1.1 404 Not Found"
    end
    status + "\r\n" + "\r\n" + output
  end

  def root_response(request)
    if request.verb == "POST"
      output = "<html>You sent a post request.</html>"
      status = "http/1.1 202 ok"
    elsif request.verb == "GET"
      output = "<html>Hello from the Server side!</html>"
      status = "http/1.1 200 ok"
    elsif request.verb == "PATCH"
      output = "<html>You sent a patch request.</html>"
      status = "http/1.1 405 ok"
    elsif request.verb == "DELETE"
      output = "<html>You sent a delete request.</html>"
      status = "http/1.1 401 ok"
    else
      output = "<html>404 Not Found</html>"
      status = "http/1.1 404 Not Found"
    end
    status + "\r\n" + "\r\n" + output
  end

  def main_page
    '<h2>Generate a Guess with a GET request and query params</h2>

    <form action="/game">
      <label>Guess: </label>
      <input type="text" name="guess">

      <input type="submit" value="Submit">
    </form>

    <h2>Generate a Guess with a POST request</h2>

    <form action="/game" method="post">
      <label>Guess: </label>
      <input type="text" name="guess">

      <input type="submit" value="Submit">
    </form>

    <h2>Change the Answer with a POST request</h2>

    <form action="/game/answer", method="post">
      <label>Answer: </label>
      <input type="text" name="answer">

      <input type="submit" value="Submit">
    </form>'
  end
end

server = Server.new
server.start
