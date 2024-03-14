%% Run samples of the ServiceQueue simulation
% 
% Collect statistics and plot histograms along the way.

% MATLAB-ism: Comment lines that start with %% and a space are treated as
% section headings.  If you click the "Run Section" button, MATLAB will
% evaluate just the commands between the section headings just before and
% just after the text cursor.  This can be really useful when you have some
% very long calculations, such as simulation runs, and some short follow-up
% commands, such as plots.

%% Set up

% Arrival rate
lambda = 1/2;

% Departure (service) rate
mu = 1/1.5;

% Number of serving stations
s = 1;

% Run 100 samples of the queue.
NumSamples = 100;

% Each sample is run up to a maximum time of 1000.
MaxTime = 1000;

%% Numbers from theory for M/M/1 queue

% Compute P(1+n) = $P_n$ = probability of finding the system in state $n$
% in the long term.
% Note that this calculation assumes s=1.
rho = 1/2;
P0 = 2/5;
nMax = 10;
P = zeros([1, nMax+1]);
P(1) = P0;
for n = 1:nMax
    P(1+n) = (3/5) * rho^n;
end

%% Run simulation samples

% This is the most time consuming calculation in the script, so let's put
% it in its own section.  That way, we can run it once, and more easlily
% run the faster calculations multiple times as we add features to this
% script.

% Reset the random number generator.  This causes MATLAB to use the same
% sequence of pseudo-random numbers each time you run the script, which
% means the results come out exactly the same.  This is a good idea for
% testing purposes.  Under other circumstances, you probably want the
% random numbers to be truly unpredictable and you wouldn't do this.
rng("default");

% We'll store our queue simulation objects in this list.
QSamples = cell([NumSamples, 1]);

% The statistics seem to come out a little weird if the log interval is too
% short, because the log entries are not independent enough.  So the log
% interval should be long enough for several arrival and departure events
% happen.
for SampleNum = 1:NumSamples
    fprintf("Working on sample %d\n", SampleNum);
    q = ServiceQueue( ...
        ArrivalRate=1/2, ...
        DepartureRate=1.5, ...
        NumServers=s, ...
        LogInterval=10);
    q.schedule_event(Arrival(1, Customer(1)));
    run_until(q, MaxTime);
    QSamples{SampleNum} = q;
end


NumInSystemSamples = cellfun( ...
    @(q) q.Log.NWaiting + q.Log.NInService, ...
    QSamples, ...
    UniformOutput=false);
%% Collect statistics

% Join numbers from all sample runs. "vertcat" is short for "vertical
% concatenate", meaning it joins a bunch of arrays vertically, which in
% this case results in one tall column.
NumInSystem = vertcat(NumInSystemSamples{:});

%% Pictures and stats for number of customers in system

% Print out mean number of customers in the system.
meanNumInSystem = mean(NumInSystem);
fprintf("Mean number in system: %f\n", meanNumInSystem);

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% MATLAB-ism: Once you've created a picture, you can use hold to cause
% further plotting function to work with the same picture rather than
% create a new one.
hold(ax, "on");

% Start with a histogram.  The result is an empirical PDF, that is, the
% area of the bar at horizontal index n is proportional to the fraction of
% samples for which there were n custonmers in the system.

k = histogram(ax,NumInSystem, Normalization="probability", BinMethod="integers");



plot(ax, 0:nMax, P, 'o', MarkerEdgeColor='k', MarkerFaceColor='r');



% Add titles and labels and such.
title(ax, "Number of customers in the system");
xlabel(ax, "Count");
ylabel(ax, "Probability");
legend(ax, "simulation", "theory");

% This sets the vertical axis to go from 0 to 0.3.
ylim(ax, [0, 0.3]);
xlim(ax, [-1, 21]);

% MATLAB-ism: You have to wait a couple of seconds for those settings to
% take effect or exportgraphics will screw up the margins.
pause(2);

% Save the picture as a PDF file.
exportgraphics(fig, "Number in system histogram.pdf");

%% Collect measurements of how long customers spend in the system

% This is a rather different calculation because instead of looking at log
% entries for each sample ServiceQueue, we'll look at the list of served
% customers in each sample ServiceQueue.


% Option two: Use cellfun twice.
% The outer call to cellfun means do something to each ServiceQueue object
% in QSamples.
% The "something" it does is to look at each customer in the ServiceQueue
% object's list q.Served and compute the time it spent in the system.
TimeInSystemSamples = cellfun( ...
    @(q) cellfun(@(c) c.DepartureTime - c.ArrivalTime, q.Served'), ...
    QSamples, ...
    UniformOutput=false);

% Again, join them all into one big column.
TimeInSystem = vertcat(TimeInSystemSamples{:});
%% Pictures and stats for time customers spend in the system

% Print out mean time spent in the system.
meanTimeInSystem = mean(TimeInSystem);
fprintf("Mean time in system: %f\n", meanTimeInSystem);

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% This time, the data is a list of real numbers, not integers.
% The option BinEdges=0:0.5:60 means to use bins (0, 0.5), (0.5, 1.0), ...
g = histogram(ax, TimeInSystem, Normalization="probability", BinEdges=0:0.5:60);

% Add titles and labels and such.
title(ax, "Time in the system");
xlabel(ax, "Time");
ylabel(ax, "Probability");

% Set ranges on the axes.
ylim(ax, [0, 0.1]);
xlim(ax, [-1, 21]);

% Wait for MATLAB to catch up.
pause(2);

% Save the picture as a PDF file.
exportgraphics(fig, "Time in system histogram.pdf");



TimesSpentWaitingSamples = cellfun( ...
    @(q) cellfun(@(c) c.BeginServiceTime - c.ArrivalTime, q.Served'), ...
    QSamples, ...
    UniformOutput=false);

% Again, join them all into one big column.
TimesSpentWaiting = vertcat(TimesSpentWaitingSamples{:});
%% Pictures and stats for time customers spend in the system

% Print out mean time spent in the system.
meanTimesSpentWaiting = mean(TimesSpentWaiting);
fprintf("Mean time in system: %f\n", meanTimesSpentWaiting);

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% This time, the data is a list of real numbers, not integers.
% The option BinEdges=0:0.5:60 means to use bins (0, 0.5), (0.5, 1.0), ...
i = histogram(ax, TimesSpentWaiting, Normalization="probability", BinEdges=0:0.5:60);

% Add titles and labels and such.
title(ax, "Time Spent Waiting in the system");
xlabel(ax, "Time");
ylabel(ax, "Probability");

% Set ranges on the axes.
ylim(ax, [0, 0.1]);
xlim(ax, [-1, 21]);

% Wait for MATLAB to catch up.
pause(2);

% Save the picture as a PDF file.
exportgraphics(fig, "Time Spent Waiting in system histogram.pdf");




TimeSpentServedSamples = cellfun( ...
    @(q) cellfun(@(c) c.DepartureTime - c.BeginServiceTime, q.Served'), ...
    QSamples, ...
    UniformOutput=false);

% Again, join them all into one big column.
TimeSpentServed = vertcat(TimeSpentServedSamples{:});
%% Pictures and stats for time customers spend in the system

% Print out mean time spent in the system.
meanTimeSpentServed = mean(TimeSpentServed);
fprintf("Mean time in system: %f\n", meanTimeSpentServed);

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% This time, the data is a list of real numbers, not integers.
% The option BinEdges=0:0.5:60 means to use bins (0, 0.5), (0.5, 1.0), ...
w = histogram(ax, TimeSpentServed, Normalization="probability", BinEdges=0:0.5:60);

% Add titles and labels and such.
title(ax, "Time Spent Served in the system");
xlabel(ax, "Time");
ylabel(ax, "Probability");

% Set ranges on the axes.
ylim(ax, [0, 0.1]);
xlim(ax, [-1, 21]);

% Wait for MATLAB to catch up.
pause(2);

% Save the picture as a PDF file.
exportgraphics(fig, "Time Spent Served in system histogram.pdf");





