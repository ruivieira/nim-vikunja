## Vikunja REST API client

import httpclient
import jsony
import options
import std/strformat

const BASE_URL = "https://app.vikunja.cloud/api/v1"

type Vikunja = object
    token*: string
    url*: string
    client*: HttpClient

type VikunjaUser* = object
  created*: string
  email*: Option[string]
  id*: int
  name*: string
  updated*: string
  username*: string

type VikunjaLable* = object
  created*: string
  created_by*: VikunjaUser
  description*: string
  hex_color*: string
  id*: int
  title*: string
  updated*: string

type VikunjaTask* = object
    assignees*: Option[VikunjaUser]
    # files
    bucket_id*: Option[int]
    cover_image_attachment_id*: Option[int]
    created*: string
    created_by*: Option[VikunjaUser]
    description*: string
    done*: bool
    done_at*: Option[string]
    due_date*: Option[string]
    end_date*: Option[string]
    hex_color*: Option[string]
    id*: Option[int]
    identifier*: string
    index*: int
    is_favorite*: bool
    kanban_position*: int
    labels*: Option[seq[VikunjaLable]]
    list_id*: int
    percent_done*: int
    position*: int
    priority*: int
    reminder_dates*: Option[seq[string]]
    repeat_after*: Option[int]
    repeat_mode*: int
    start_date*: Option[string]
    # subscription
    title*: string
    updated*: string

type VikunjaCreateTask* = object
    description*: string
    done*: bool
    list_id*: int
    title*: string

proc createTask*(title: string, list_id: int, description: string = "", done: bool = false): VikunjaCreateTask =
    return VikunjaCreateTask(description: description, done: done, title: title, list_id: list_id)

proc newVikunja*(token: string, url: string = BASE_URL): Vikunja =
    return Vikunja(token: token, url: url, client: newHttpClient())

proc buildGETRequest(vikunja: Vikunja, url: string): Response =
    let headers = newHttpHeaders()
    headers["Authorization"] = "Bearer " & vikunja.token
    let response = request(vikunja.client, url, HttpMethod.HttpGet, "", headers)
    echo response.body
    return response

proc buildPUTRequest(vikunja: Vikunja, url: string, payload: string): Response =
    let headers = newHttpHeaders()
    headers["Authorization"] = "Bearer " & vikunja.token
    headers["Content-Type"] = "application/json"
    let response = request(vikunja.client, url, HttpMethod.HttpPut, payload, headers)
    echo response.body
    return response

proc getAll[T](vikunja: Vikunja, url: string): seq[T] =
    let response = buildGETRequest(vikunja, url)
    echo response.body
    let json = response.body.fromJson(seq[T])
    return json

proc getSingle[T](vikunja: Vikunja, url: string): T =
    let response = buildGETRequest(vikunja, url)
    let json = response.body.fromJson(T)
    return json

proc putSingle[T](vikunja: Vikunja, url: string, body: T): Response =
    let payload = body.toJson()
    echo payload
    let response = buildPUTRequest(vikunja, url, payload)
    return response


proc getAllTasks*(vikunja: Vikunja): seq[VikunjaTask] =
    let url = &"{vikunja.url}/tasks/all"
    let tasks = getAll[VikunjaTask](vikunja, url)
    return tasks

proc getTask*(vikunja: Vikunja, id: int): VikunjaTask =
    let url = &"{vikunja.url}/tasks/{id}"
    let task = getSingle[VikunjaTask](vikunja, url)
    return task

proc createTask*(vikunja:Vikunja, task: VikunjaCreateTask) =
    let url = &"{vikunja.url}/lists/{task.list_id}"
    let response = putSingle[VikunjaCreateTask](vikunja, url, task)
    echo response.body
    