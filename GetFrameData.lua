local movie_loaded = false; -- This tells if the program has initialized for the movie
local movie_filename = ""; -- Will hold the movie file name (.fm2)
local output_filename = ""; -- Will hold the output file name (.txt)
local handle; -- For ouputing to the file

previous_input = {};
input2 = {};
local latches = 0;
local lagged = false;
local high_latch = false;


function count_latches( )
  if high_latch == false then
    latches = latches + 1;
    high_latch = true;
  else
    high_latch = false;
  end;
end;

memory.registerwrite(0x4016, count_latches);

while true do
  if (movie.active() == true) then
        -- When a movie is loaded for the first time, we need to do some setup
        if (movie_loaded == false) then
            -- First, restart the movie at the beginning
            movie.playbeginning();
            
            -- Lets make up the output filename
            -- Take the video name, remove the .fm2 and replace with .txt
            movie_filename = movie.getname();
            output_filename = string.sub(movie_filename, 0, string.len(movie_filename)-4) .. ".txt";
            
            -- Print it out for debugging
            print(output_filename);
            
            -- Setup the file handle to write to it
            handle = io.open(output_filename, "w");
            
            -- Now we are ready to go.
            movie_loaded = true;
        end;
        
       if latches > 0 then
        
        print (movie.framecount() .. "|" .. latches);
--        for i=1,latches do
            local number = 0;
            if (previous_input.right == true)  then number = OR(number,BIT(7)); end;
            if (previous_input.left == true)   then number = OR(number,BIT(6)); end;
            if (previous_input.down == true)   then number = OR(number,BIT(5)); end;
            if (previous_input.up == true)     then number = OR(number,BIT(4)); end;
            if (previous_input.start == true)  then number = OR(number,BIT(3)); end;
            if (previous_input.select == true) then number = OR(number,BIT(2)); end;
            if (previous_input.B == true)      then number = OR(number,BIT(1)); end;
            if (previous_input.A == true)      then number = OR(number,BIT(0)); end;
            handle:write(string.char(number));
--        end;
       end;
       
       latches = 0;
   
   else
        -- If the movie has ended, then our work here is done. Clean up
        if (movie_loaded == true) then
            handle:close();
            print("DONE");
            movie_loaded = false;
            frame = 0;
        end;
    end;
   emu.frameadvance();
   --previous_input = input2;
   previous_input = joypad.get(1);
   
end;

