#include "GPUCipherDevice.hpp"

template<typename S, typename F>
paracrypt::GPUCipherDevice<S,F>::~GPUCipherDevice() {
	//for(boost::map<int,S>::iterator iter = this->streams.begin(); iter != this->streams.end(); ++iter)
	//{
	//	delStream(iter->first);
	//}
}

template<typename S, typename F>
int paracrypt::GPUCipherDevice<S,F>::getGridSize(int n_blocks, int threadsPerCipherBlock) {
    int gridSize = n_blocks * threadsPerCipherBlock / this->getThreadsPerThreadBlock();
    return gridSize;
}

template<typename S, typename F>
int paracrypt::GPUCipherDevice<S,F>::addStream() {
	//boost::unique_lock< boost::shared_mutex > lock(this->streams_access);
	//int id = this->streams.size();
	//this->streams[id] = newStream();
	return 0;//return id;
}

template<typename S, typename F>
void paracrypt::GPUCipherDevice<S,F>::delStream(int stream_id) {
	//boost::unique_lock< boost::shared_mutex > lock(this->streams_access);
	//freeStream(this->streams[stream_id]);
	//this->streams.erase(stream_id);
}

template<typename S, typename F>
S paracrypt::GPUCipherDevice<S,F>::acessStream(int stream_id) {
	//boost::shared_lock < boost::shared_mutex > lock(this->streams_access);
	//return this->streams[stream_id];
}
