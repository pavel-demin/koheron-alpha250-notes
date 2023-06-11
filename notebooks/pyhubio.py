import socket
import numpy as np


class PyhubTCP:
    def __init__(self, host="192.168.1.100", port=1001):
        self.address = (host, port)
        self.socket = None

    def start(self):
        if self.socket:
            return
        self.socket = socket.create_connection(self.address, 1)

    def stop(self):
        if self.socket is None:
            return
        self.socket.close()
        self.socket = None

    def read(self, data, port=1, addr=0):
        if self.socket is None:
            return
        view = data.view(np.uint8)
        for part in np.split(view, np.arange(16777216, view.size, 16777216)):
            view = part.view(np.uint8)
            size = part.size
            incr = np.arange(0, size, 65536, np.uint64)
            rlen = np.full_like(incr, 65536)
            mod = size % 65536
            if mod > 0:
                rlen[-1] = mod
            command = rlen << 28 | (port & 0x7) << 24 | (addr + incr) & 0xFFFFFF
            self.socket.sendall(command.tobytes())
            offset = 0
            limit = view.size
            while offset < limit:
                buffer = self.socket.recv(65536)
                buffer = np.frombuffer(buffer, np.uint8)
                size = buffer.size
                if size > limit - offset:
                    size = limit - offset
                view[offset : offset + size] = buffer[:size]
                offset += size
            addr += part.size

    def write(self, data, port=0, addr=0):
        if self.socket is None:
            return
        view = data.view(np.uint8)
        for part in np.split(view, np.arange(65536, view.size, 65536)):
            size = part.size
            command = np.uint64([1 << 52 | size << 28 | (port & 0x7) << 24 | addr & 0xFFFFFF])
            addr += part.size
            self.socket.sendall(command.tobytes())
            self.socket.sendall(part.tobytes())

    def edge(self, data, mask, positive=True, addr=0):
        if self.socket is None:
            return data
        command = np.uint64([1 << 52 | 1 << 28 | addr & 0xFFFFFF])
        view = command.view(np.uint8)
        lo = np.uint8([data & ~mask])
        hi = np.uint8([data | mask])
        if positive:
            sequence = np.concatenate((view, lo, view, hi))
            result = hi
        else:
            sequence = np.concatenate((view, hi, view, lo))
            result = lo
        self.socket.sendall(sequence.tobytes())
        return result

    def program(self, path):
        if self.socket is None:
            return
        data = np.fromfile(path, np.uint8)
        size = data.size
        command = np.uint64([2 << 52 | size << 28])
        self.socket.sendall(command.tobytes())
        self.socket.sendall(data.tobytes())
