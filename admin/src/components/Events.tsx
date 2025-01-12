import { useContext, useMemo, useState } from "react";
import { DeleteModal } from "./DeleteModal";
import {
  EntryModal,
  EntryForm,
  NumberEntryForm,
  OptionEntryForm,
  FreeEntryForm,
  DateEntryForm,
} from "./EntryModal";
import { HButton } from "./HButton";
import {
  ButtonSizer,
  CenterText,
  ListCardBody,
  ListCardBox,
  ListCardButtons,
  ListCardDescription,
  ListCardTitle,
} from "./ListCard";
import { SearchBar } from "./SearchBar";
import { ServerDataContext } from "./ServerData";

import { compareTwoStrings } from "string-similarity";
import { EventDto } from "../dto/event.dto";
import { AlertModal } from "./AlertModal";

function EventCard(props: {
  event: EventDto;
  onSelect: () => void;
  onEdit: () => void;
  onDelete: () => void;
  onSetDefault: () => void;
}) {
  const requiredText =
    props.event.requiredMembers < 0
      ? "Any Amount"
      : props.event.requiredMembers;

  const rewardingMethod =
    props.event.rewardType === "limited_time" ? "Limited" : "Unlimited";

  const affirmOfBool = (val: boolean) => (val ? "Yes" : "No");

  return (
    <>
      <ListCardBox>
        <ListCardTitle>
          {props.event.name}
          <ButtonSizer>
            <HButton onClick={props.onSelect} float="right">
              SELECT
            </HButton>
          </ButtonSizer>
        </ListCardTitle>
        <ListCardDescription>{props.event.description}</ListCardDescription>
        <ListCardBody>
          Id: <b>{props.event.id}</b>
          <br />
          Available Until: <b>
            {new Date(props.event.endTime).toString()}
          </b>{" "}
          <br />
          Required Players: <b>{requiredText}</b> <br />
          Rewarding Method: <b>{rewardingMethod}</b> <br />
          Minimum Rewarding Score: <b>{props.event.minimumScore}</b> <br />
          Challenge Count: <b>{props.event.challengeIds.length}</b> <br />
          Reward Count: <b>{props.event.rewardIds.length}</b> <br />
          Publicly Visible: <b>{affirmOfBool(props.event.indexable)}</b> <br />
          Latitude: <b>{props.event.latitude}</b>, Longitude:{" "}
          <b>{props.event.longitude}</b> <br />
        </ListCardBody>
        <ListCardButtons>
          <HButton onClick={props.onSetDefault}>SET DEFAULT</HButton>
          <HButton onClick={props.onDelete} float="right">
            DELETE
          </HButton>
          <HButton onClick={props.onEdit} float="right">
            EDIT
          </HButton>
        </ListCardButtons>
      </ListCardBox>
    </>
  );
}

function makeForm() {
  return [
    { name: "Name", characterLimit: 256, value: "" },
    { name: "Description", characterLimit: 2048, value: "" },
    { name: "Required Members", value: -1, min: -1, max: 99 },
    {
      name: "Reward Type",
      options: ["Unlimited", "Limited"],
      value: 0,
    },
    { name: "Minimum Score for Reward", value: 1, min: 1, max: 999999 },
    { name: "Publicly Visible", options: ["No", "Yes"], value: 0 },
    { name: "Available Until", date: new Date("2050") },
  ] as EntryForm[];
}

function fromForm(form: EntryForm[], id: string): EventDto {
  return {
    id,
    requiredMembers: (form[2] as NumberEntryForm).value,
    rewardType:
      (form[3] as OptionEntryForm).value === 0 ? "perpetual" : "limited_time",
    name: (form[0] as FreeEntryForm).value,
    description: (form[1] as FreeEntryForm).value,
    indexable: (form[5] as OptionEntryForm).value === 1,
    endTime: (form[6] as DateEntryForm).date.toUTCString(),
    rewardIds: [],
    challengeIds: [],
    defaultChallengeId: "",
    minimumScore: (form[4] as NumberEntryForm).value,
    latitude: 0,
    longitude: 0,
  };
}

function toForm(event: EventDto) {
  return [
    { name: "Name", characterLimit: 256, value: event.name },
    { name: "Description", characterLimit: 2048, value: event.description },
    {
      name: "Required Members",
      value: event.requiredMembers,
      min: -1,
      max: 99,
    },
    {
      name: "Reward Type",
      options: ["Unlimited", "Limited"],
      value: event.rewardType === "perpetual" ? 0 : 1,
    },
    {
      name: "Minimum Score for Reward",
      value: event.minimumScore,
      min: 1,
      max: 999999,
    },
    {
      name: "Publicly Visible",
      options: ["No", "Yes"],
      value: event.indexable ? 1 : 0,
    },
    { name: "Available Until", date: new Date(event.endTime) },
  ] as EntryForm[];
}

export function Events() {
  const serverData = useContext(ServerDataContext);
  const [isCreateModalOpen, setCreateModalOpen] = useState(false);
  const [isEditModalOpen, setEditModalOpen] = useState(false);
  const [isDeleteModalOpen, setDeleteModalOpen] = useState(false);
  const [selectModalOpen, setSelectModalOpen] = useState(false);
  const [form, setForm] = useState(() => makeForm());
  const [currentId, setCurrentId] = useState("");
  const [query, setQuery] = useState("");
  const selectedOrg = serverData.organizations.get(serverData.selectedOrg);

  return (
    <>
      <AlertModal
        description="To create an event, select an organization."
        isOpen={selectModalOpen}
        onClose={() => setSelectModalOpen(false)}
      />
      <EntryModal
        title="Create Event"
        isOpen={isCreateModalOpen}
        entryButtonText="CREATE"
        onEntry={() => {
          serverData.updateEvent({
            ...fromForm(form, ""),
            initialOrganizationId: serverData.selectedOrg,
          });
          setCreateModalOpen(false);
        }}
        onCancel={() => {
          setCreateModalOpen(false);
        }}
        form={form}
      />
      <EntryModal
        title="Edit Event"
        isOpen={isEditModalOpen}
        entryButtonText="EDIT"
        onEntry={() => {
          const { challengeIds, rewardIds, defaultChallengeId } =
            serverData.events.get(currentId)!;
          serverData.updateEvent({
            ...fromForm(form, currentId),
            defaultChallengeId,
            challengeIds,
            rewardIds,
          });
          setEditModalOpen(false);
        }}
        onCancel={() => {
          setEditModalOpen(false);
        }}
        form={form}
      />
      <DeleteModal
        objectName={serverData.events.get(currentId)?.name ?? ""}
        isOpen={isDeleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onDelete={() => {
          serverData.deleteEvent(currentId);
          setDeleteModalOpen(false);
        }}
      />
      <SearchBar
        onCreate={() => {
          if (!selectedOrg) {
            setSelectModalOpen(true);
            return;
          }
          setForm(makeForm());
          setCreateModalOpen(true);
        }}
        onSearch={(query) => setQuery(query)}
      />
      {serverData.selectedOrg === "" ? (
        <CenterText>Select an organization to view events</CenterText>
      ) : serverData.organizations.get(serverData.selectedOrg) ? (
        serverData.organizations.get(serverData.selectedOrg)?.events.length ===
          0 && <CenterText>No events in organization</CenterText>
      ) : (
        <CenterText>Error getting events</CenterText>
      )}
      {Array.from(
        serverData.organizations
          .get(serverData.selectedOrg)
          ?.events.map((evId) => serverData.events.get(evId)!)
          .filter((ev) => !!ev) ?? []
      )
        .sort(
          (a, b) =>
            compareTwoStrings(b.name, query) -
            compareTwoStrings(a.name, query) +
            compareTwoStrings(b.description, query) -
            compareTwoStrings(a.description, query)
        )
        .map((ev) => (
          <EventCard
            key={ev.id}
            event={ev}
            onSelect={() => serverData.selectEvent(ev.id)}
            onDelete={() => {
              setCurrentId(ev.id);
              setDeleteModalOpen(true);
            }}
            onSetDefault={() => {
              if (serverData.selectedOrg !== "") {
                const org = serverData.organizations.get(
                  serverData.selectedOrg
                )!;
                org.defaultEventId = ev.id;
                serverData.updateOrganization(org);
              }
            }}
            onEdit={() => {
              setCurrentId(ev.id);
              setForm(toForm(ev));
              setEditModalOpen(true);
            }}
          />
        ))}
    </>
  );
}
