def getclock()
    time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    time * 1000 * 1000 * 1000
end