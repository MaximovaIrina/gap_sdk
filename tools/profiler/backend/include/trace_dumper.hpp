/*
 * Copyright (C) 2019 Green_waves Technologies
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __TRACE_DUMPER_HPP__
#define __TRACE_DUMPER_HPP__

#include "trace_dumper_types.h"
#include "trace_dumper_utils.h"

#include <string>
#include <fstream>
#include <unordered_map>

#include <sys/types.h>
#include <regex.h>

class Trace
{
public:
	Trace(std::string path, int id, uint32_t type, int width);

	std::string path;
	int id;
	uint32_t type;
	int width;

	bool operator< (const Trace& t) const {return (this->path.compare(t.path) < 0);}
};

class trace_packet
{
public:
	trace_packet();
	virtual ~trace_packet();
	void dump() const;

	ed_header_t header;
	ed_conf_t conf;
	ed_reg_trace_t reg_trace;
	Trace *trace;
	uint64_t timestamp;
	uint8_t *data;
	int size;
};

class trace_dumper_client;

class trace_dumper_trace
{
public:
    trace_dumper_trace(trace_dumper_client *client, int id, ed_trace_type_e type, int width);

    void dump(int64_t timestamp, uint8_t *value, int width);

private:
	int id;
    ed_trace_type_e type;
    int width;
    trace_dumper_client *client;
    int id_size;
};

class trace_dumper_server
{
public:
		trace_dumper_server(std::string filepath);

		int open();
		virtual int get_packet(trace_packet *packet);
		uint64_t get_timestamp() const {return timestamp;}

private:

	std::string filepath;
	std::ifstream file;

protected:
	uint64_t timestamp;
	std::unordered_map<int, Trace *> traces;
};



class trace_dumper_client
{
public:
    trace_dumper_client(std::string filepath);

    int open(ed_conf_timescale_e timescale=ED_CONF_TIMESCALE_PS);
    void close();

    trace_dumper_trace *reg_trace(std::string path, uint32_t id, ed_trace_type_e type, uint32_t width);

    int dump_trace(int64_t timestamp, int id, int id_size, ed_trace_type_e type, uint8_t *value, int width);

private:
	std::string filepath;
	std::ofstream file;
	int64_t current_timestamp;
};


#endif
