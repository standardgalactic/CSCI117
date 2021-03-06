%%%% CSci 117, Lab 7 %%%%
%%%% Joshua Francisco %%%%

% Answer written questions within block comments, i.e. /* */
% Answer program related questions with executable code (executable from within the Mozart UI) 

% Note: While many of these questions are based on questions from the book, there are some
% differences; namely, extensions and clarifications. 


% Part 1: Conceptual

% Q1 Thread semantics. 
% Consider the following variation of the statement used in Section 4.1.3 to illustrate thread semantics:

local B in           
  thread         % S1
    B=true       % T1
  end
  thread         % S2
    B=false      % T2
  end
  if B then      % S2
    {Browse yes} % S2.1
  end
end

% For this exercise, do the following:
%  (a) Enumerate all possible executions of this statement.
/*
There is one stack with two statements where thread (S1) B=true (T1) end if B then (S3) {Browse yes} (S3.1) end. After executing thread (S1), then there are two stacks or threads%     (S1 and S2) with b=true (T1) and if (S3). Since b is determined, the second thread, which has if (S3), is suspended as it is false. After the first stack is empty, the second thread  (S2) is ready with if B then (S3) and {Browse yes} (S3.1) end. The stack empties and if (S3) executes. {Browse yes} (S3.1) is left while B = true and displays yes.
*/
%  (b) Some of these executions cause the program to terminate abnormally. 
%      Make a small change to the program to avoid these abnormal terminations.


% Q2 Concurrent Fibonacci. 
% Consider the following sequential definition of the Fibonacci function:
declare
fun {Fib X}
  if X=<2 then 1 
  else
    {Fib X-1}+{Fib X-2}
  end 
end

{Browse {Fib 26}}

% Concurrent Definition
declare
fun {Fib X}
   if X=<2 then 1
   else thread {Fib X-1} end + {Fib X-2} end
end

{Browse {Fib 28}}

% and compare it with the concurrent definition given in Section 4.2.3. 
% Run both on the Mozart system and compare their performance. How much faster is the sequential definition? 
%    Use the following inputs - 3,5,10,15,20,25,26,27,28
%    (Give your inputs, run time, and thread count in your experimentation)   
%    Note - Page 255 describes how to use the Oz Panel to view the number of threads created!
% How many threads are created by the concurrent call {Fib N} as a function of N?
% the number of threads created as represented by N can vary depending on the value of N.
/* Non Concurrent Definition
Input: 3, Run Time: 0.01s, Thread Count: 13
Input: 5, Run Time: 0.01s,  Thread Count: 17
Input: 10, Run Time: 0.01s, Thread Count: 27
Input: 15, Run Time: 0.01s, Thread Count: 13
Input: 20, Run Time: 0.01s, Thread Count: 38
Input: 25, Run Time: 0.04s, Thread Count: 18
Input: 26, Run Time: 0.01s, Thread Count: 13
Input: 27, Run Time: 0.01s, Thread Count: 12
Input: 28, Run Time: 0.03s, Thread Count: 13
      
*/
/* Concurrent Definition
Input: 3, Run Time: 0.01s Thread Count: 17
Input: 5, Run Time: 0.01s, Thread Count: 15
Input: 10, Run Time: 0.01s, Thread Count: 65
Input: 15, Run Time: 0.01s, Thread Count: 620
Input: 20, Run Time: 0.01s, Thread Count: 6779
Input: 25, Run Time: 0.07s, Thread Count: 75039
Input: 26, Run Time: 0.15s, Thread Count: 121404
Input: 27, Run Time: 0.23s, Thread Count: 196428
Input: 28, Run Time: 0.22s, Thread Count: 317826

*/
% Q3 Order-determining concurrency. 
% Explain what happens when executing the following:

declare A B C D in 
thread D=C+1 end 
thread C=B+1 end 
thread A=1 end 
thread B=A+1 end 
{Browse D}

% In what order are the threads created? 
% In what order are the additions done? 
% What is the final result? 
% Compare with the following:

declare A B C D in 
A=1
B=A+1
C=B+1
D=C+1
{Browse D}

% Here there is only one thread. In what order are the additions done? What is the final result? 
% What do you conclude?

/*
The order of creation of thread is thread D -> thread C -> thread B -> thread A
Explanation: When we browse D, first thread D will be created i.e thread D= C+1 , thread D has dependency on thread C for its completion so thread C= B+1 will be created, further more thread C(thread C= B+1) has dependency on thread B=A+1, thus thread B=A+1 will be created, again thread B = A+1 has dependency on thread A= 1, thus thread A=1 is created.
The order of Addition will be :
First thread A will be completed as it has no dependency on any other threads
So A=1,
Thread B has dependency on thread A only so thread B will execute afterwards,
i.e B= A+1=2
Then Thread C has dependency on thread B only so thread C will execute afterwards,
i.e C= B+1 =3;
Then Thread D has dependency on thread C only so thread D will execute afterwards,
D = C+1=4
So threads will be executed in thread A-> thread B-> thread C-> thread D order.
Final result is D=4.
In second case ,As there is only one thread, So when we Browse thread D, Following operations will take place
D= C+1
C will be replaced by B+1
D= B+1+1
B will be replaced by A+1
D =A+1+1+1
A will be replaced by 1
D= 1+1+1+1=4
Final result is 4.

The conclusion from above scenario is whether we do operation by using multiple treads or by using single thread, the result of operation will be same. However ,In general life we prefer multithreading as it is more efficient, faster and less dependent on any particular thread.

*/

% Q4 Thread Effeciency.
% Take the nested flatten question from lab 5 (which is a non-iterative function)

fun {Flatten Xs}
  proc {FlattenD Xs ?Ds}
    case Xs
    of nil then Y in Ds=Y#Y
    [] X|Xr andthen {IsList X} then Y1 Y2 Y4 in
      Ds=Y1#Y4 
      {FlattenD X Y1#Y2}   % ***************** A *********************
      {FlattenD Xr Y2#Y4}
    [] X|Xr then Y1 Y2 in
      Ds=(X|Y1)#Y2 
      {FlattenD Xr Y1#Y2}
    end 
  end Ys
  in {FlattenD Xs Ys#nil} Ys
end

% If we replace statement A with 
%    thread {FlattenD X Y1#Y2} end
% what will happen to the stack size as the program executes?
% Would you consider this function iterative?
% Do you think threading will make this function more effecient?

/*
Q4) The stack size will not increase but instead another stack will be created when the thread statement executes. That new thread stack will increase in size until its end. The threaded version of the FlattenD function is not considered iterative. If done correctly and optimally, threading the function will make the function more efficient.
*/

% Part 2: Streams 

% Q1 Producers, Filters, and Consumers

fun {Generate N Limit} 
  if N<Limit then
    N|{Generate N+1 Limit} 
  else nil 
  end
end

% Filter Function
fun {Filter L1 Xs} %taking some string of numbers and pulling out elements
case Xs of
   nil then nil
[] X|Xr then
   if X > 1 = 1 then
      X|{Filter L1 Xr}
      else 
      {filter {1 Xs}}



% (a) Using the above generator on a list from [0 1 2 ... 100] and threading, write functions that 
%        filter out all odd numbers
%        filter out all multiples of 4 
%        filter out all numbers greater than 7 and less than 77




% (a') Place the generator, three filters, and reader all in separate threads (where the reader simply displays elements
%      one at a time)
%      The stream will look like the following:
%      [Generator]->[remove odds]->[remove multiples of 4]->[remove numbers (7...77)]->[Display element]

fun {Generate N Limit} 
  if N<Limit then
    {Delay 100}
    N|{Generate N+1 Limit} 
  else nil 
  end
end
% Use the above generator so there is a pause between elements being created
% Describe the flow of the first 9 elements as they move through the chain. What threads are awakened, and when?
/*
a') Each element of the list has a delay of 100 seconds. Depending on which filter is appropriate for a particular element of the list, a thread is awakened at that element of the list. This happens at an odd number, multiple of 4, or when there are numbers greater than 7 and numbers greater than 77.
*/

% (b) Using the above generator on a list from [0 1 2 ... 100] and threading, write consumers that  
%        return the list of sums of every pair of consecutive integers, i.e. [0+1 2+3 4+5 ...] = [1 5 9 ...]
%        return the sum of all odd numbers (you will need a filter and fold operation)


declare
fun {Generate N Limit} 
  if N<Limit then
    {Delay 100}
    N|{Generate N+1 Limit} 
  else nil 
  end
end

L = {Generate 0 7}
M = [1 3 7 6 5 8 9]

fun {ConseqSum Xs}
   case Xs of nil then nil
   [] X|Xr andthen Xr == nil then [X]
   else
      
   local
      X = Xs.1
      Y = Xs.2.1
      Ys = Xs.2.2
   in
      if (X+1==Y) then (X + Y)|{ConseqSum Ys} else X|{ConseqSum Y|Ys} end
   end
   end
end

local
fun {F2 Xs} %filter evens
   case Xs of nil then nil
   [] X|Xr then if {IsEven X} then {F2 Xr} else X|{F2 Xr} end
   end 
end
fun {Foldsum Xs}
   case Xs of nil then nil
   [] X|Xr andthen Xr == nil then X
   [] X|Xr then X+{Foldsum Xr}
   end
end

in
fun {Oddsum Xs}
   case Xs of nil then nil
   [] X|Xr andthen Xr == nil then X
   [] X|Xr then {Foldsum {F2 Xs}}
   end
end
end

{Browse {Oddsum L}}

% Q2 Prime number filter
% Using the above generator on a list from [0 1 2 ... 1000] filter out all prime numbers
% The filter works as follows:
%     Maintain a list of primes, with the inital singleton list [2]
%     At each value n, check if n is divisible by any of the primes in your list
%     from [2 .. m] (where m^2 < n)
%      - if n is divisible by at least one of these primes, keep it in the stream
%      - otherwise, n is prime, so it will be added to the list of primes, and removed from the stream

declare
L = [7 15 6 9 11]

fun{Divider X Ys}
   if Ys == nil then X else
      if X == 1 then nil else
     if X == 0 then nil else
   if (X mod Ys.1 == 0) then nil else {Divider X Ys.2}
   end
   end
   end
   end
end

fun{FprimeHelp Xs Ys}
   case Xs of nil then Ys
   [] X|Xr then local Yz = {Divider X Ys} in
    if Yz == nil then {FprimeHelp Xr Ys} else {FprimeHelp Xr Yz|Ys} end end     
   end
end

fun{Fprime Xs}   
   case Xs of nil then nil
   [] X|Xr then {FprimeHelp Xs [3 2]} 
   end
end

{Browse {Fprime L}}



% Q3 Digital logic simulation. 
/*
In this exercise we will design a circuit to add n- bit numbers and simulate it using the technique of Section 4.3.5. Given two n-bit binary numbers, (xn???1...x0)2 and (yn???1...y0)2. We will build a circuit to add these numbers by using a chain of full adders, similar to doing long addition by hand. The idea is to add each pair of bits separately, passing the carry to the next pair. We start with the low-order bits x0 and y0. Feed them to a full adder with the third input z = 0. This gives a sum bit s0 and a carry c0. Now feed x1, y1, and c0 to a second full adder. This gives a new sum s1 and carry c1. Continue this for all n bits. The final sum is (sn???1...s0)2. For this exercise, program the addition circuit using full adders. Verify that it works correctly by feeding it several additions.
*/
% GateMaker, FullAdder, and all the accompanying binary operatins can be found on pages 273,274 as well as a diagram of the full adder
% You will need to update your FullAdder procedure, because your carry values are determined after each step in the adder
% Remark - since you have an initial value of Z, namely 0, you would like your Z to look like [ _ _ _ _ ... 0] where the first few
%          elements are filled in as you proceed in the algoirthm, however, the natural way to write Z would be to declare an unbound
%          variable Zf and have Z = 0|Zf. The trick here is appropriate using reverse!











