package com.xiaomi.jinping;

import org.apache.log4j.Logger;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.DELETE;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.QueryParam;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.core.MediaType;

// Will map the resource to the URL people
@Path("/people")
public class PeopleResource {
    Logger logger = Logger.getLogger(PeopleResource.class.getName());

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String echo(@QueryParam("text") String text) {
        return text;
    }

    @GET
    @Path("{name}")
    @Produces(MediaType.APPLICATION_JSON)
    public PeopleObject getPeople(@PathParam("name") String name) {
        logger.debug("get people "+ name);
        PeopleObject p = MemoryStore.getInstance().get(name);
        return p;
    }

    @PUT
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public PeopleObject newPeople(PeopleObject p) {
        logger.debug("new people "+ p.getName() + " at age " + p.getAge());
        MemoryStore.getInstance().set(p);
        return p;
    }

    @DELETE
    @Path("{name}")
    public void deletePeople(@PathParam("name") String name) {
        logger.debug("delete people "+ name);
        MemoryStore.getInstance().delete(name);
    }

    @POST
    @Path("{name}")
    @Consumes(MediaType.APPLICATION_JSON)
    public void updatePeople(@PathParam("name") String name, PeopleObject p) {
        logger.debug("update people "+ name);
        p.setName(name);
        MemoryStore.getInstance().set(p);
    }
}
