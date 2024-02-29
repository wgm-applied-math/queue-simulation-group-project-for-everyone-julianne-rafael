function q = test_ServiceQueue(max_time)
    % test_ServiceQueue Basic test of the ServiceQueue class.
    %
    % q = test_ServiceQueue(max_time) - Schedule one customer to arrive at
    % time 1, then run the queue until its internal clock passes max_time.
    % The default for max_time is 100.
    arguments
        max_time = 200.0;
    end
    q = ServiceQueue(LogInterval=1, NumServers=2);
    q.schedule_event(Arrival(1, Customer(1)));
    while q.Time < max_time
        handle_next_event(q);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Histogram 1: Waiting Times
    waiting_times = served_customer_times(q);
    figure;
    histogram(waiting_times, 'BinWidth', 1);
    title('Waiting Times');
    xlabel('Time Spent Waiting');
    ylabel('Frequency');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Histogram 2: Time Spent in Queue
    % Corrected code
    waiting_in_queue = cellfun(@(customer) customer.BeginServiceTime - customer.ArrivalTime, q.Served);
    figure;
    edges = 0:.01:.1;  
    histogram(waiting_in_queue, 'BinEdges', edges);
    title('Time Spent in Queue');
    xlabel('Time');
    ylabel('Frequency');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Histogram 3: Time Served
    time_served = cellfun(@(customer) customer.DepartureTime - customer.BeginServiceTime, q.Served);
    figure;
    edges = 0:.5:7; 
    histogram(time_served, 'BinEdges', edges);
    title('Time Served');
    xlabel('Time');
    ylabel('Frequency');
end
