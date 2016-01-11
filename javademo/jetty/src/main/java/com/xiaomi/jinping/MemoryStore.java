package com.xiaomi.jinping;

import net.spy.memcached.MemcachedClient;

import java.net.InetSocketAddress;

import net.spy.memcached.internal.OperationFuture;
import org.apache.log4j.Logger;

/**
 * Created by qujinping on 16/1/6.
 */
public class MemoryStore {
    private static volatile MemoryStore instance = null;

    private Logger logger = Logger.getLogger(MemoryStore.class.getName());

    static String host = "memcached";
    static int port =  11211;
    private volatile MemcachedClient cli = null;

    // private constructor
    private MemoryStore(String host, int port) {
        try {
            // Spy memcached client takes responsebility of establishing & maintaining connection to the memcached server
            // however, we need to implicitly handle failure of resolving hostname.
            cli = new MemcachedClient(
                    new InetSocketAddress(host, port));
            logger.info("Got a logical connection to memcached(" + host + ":" + port + ")");
        }
        catch(Exception ex) {
            logger.error("Failed to resolve hostname of memcached(" + host + ":" + port + "). Catch exception: \n " + ex.getStackTrace().toString());
        }
    }

    public boolean set(PeopleObject p) {
        OperationFuture<Boolean> op =  cli.set(p.getName(), 300, new Integer(p.getAge()));
        try {
            return op.get().booleanValue();
        }
        catch(Exception e) {
            logger.error("Failed to set " + p);
            return false;
        }
    }

    public PeopleObject get(String name) {
        try {
            Integer age = (Integer) cli.get(name);
            PeopleObject p = new PeopleObject();
            p.setName(name);
            p.setAge(age.intValue());
            return p;
        }
        catch(Exception e) {
            logger.error("Failed to get people of " + name);
            return null;
        }
    }

    public boolean delete(String name) {
        try {
            OperationFuture<Boolean> op = cli.delete(name);
            return op.get();
        }
        catch(Exception e) {
            logger.error("Failed to delete people " + name);
            return false;
        }
    }

    public static MemoryStore getInstance() {
        if (instance == null) {
            synchronized (MemoryStore.class) {
                // Double check
                if (instance == null) {
                    instance = new MemoryStore(host, port);
                }
            }
        }
        return instance;
    }
}
