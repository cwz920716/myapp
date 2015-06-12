#include <functional>
#include <chrono>
#include <future>
#include <cstdio>
#include <stdlib.h>
#include <pthread.h>
#include <string>
#include <iostream>
#include <sstream>

class later
{
public:
    template <class callable, class... arguments>
    later(int after, bool async, callable&& f, arguments&&... args)
    {
        std::function<typename std::result_of<callable(arguments...)>::type()> task(std::bind(std::forward<callable>(f), std::forward<arguments>(args)...));

        if (async)
        {
            std::thread([after, task]() {
                std::this_thread::sleep_for(std::chrono::nanoseconds(after));
                task();
            }).detach();
        }
        else
        {
            std::this_thread::sleep_for(std::chrono::nanoseconds(after));
            task();
        }
    }

};

const int throughput_rps = 1;
const int gap_in_ns = 1000000000 / throughput_rps;
const int limit = 10;
int counter = 0;

void *send_req(void *arg) 
{
    int qid = 1;

    std::stringstream cmd;
    cmd << "nodejs webc.js " << qid;
    auto now = std::chrono::high_resolution_clock::now();
    std::cout << now.time_since_epoch().count() << "ns\n";
    system(cmd.str().c_str());
    return NULL;
}

int generateRequest()
{
    pthread_t tid;
    pthread_create(&tid, NULL, send_req, NULL);
    if (counter++ < limit) {
        later another(gap_in_ns, false, generateRequest);
    }
}

int main()
{
    later first(gap_in_ns, false, generateRequest);

    std::cout << "Press Any Key to Continue\n";  
    getchar();    
    return 0;
}
